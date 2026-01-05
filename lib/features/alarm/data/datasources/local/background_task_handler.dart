import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart'
    hide NotificationVisibility;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geo_alarm/features/alarm/domain/entities/alarm.dart';
import 'package:geo_alarm/features/alarm/data/models/alarm_model.dart';

/// Handler que se ejecuta en un Isolate separado para monitorear ubicación
/// y calcular distancias a las alarmas activas.
///
/// Este handler es resiliente y continúa funcionando incluso si la UI es cerrada.
@pragma('vm:entry-point')
void backgroundTaskHandler() async {
  debugPrint('[TASK_HANDLER] Iniciando en Isolate separado...');

  // Inicializar el receptor de tareas en segundo plano
  FlutterForegroundTask.setTaskHandler(GeofenceTaskHandler());
}

/// Implementación del handler de tareas que se ejecuta en el Isolate
class GeofenceTaskHandler extends TaskHandler {
  Isar? _isar;
  StreamSubscription<Position>? _positionSubscription;
  List<Alarm> _activeAlarms = [];
  Position? _lastPosition;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('[TASK_HANDLER] onStart llamado');

    try {
      // Inicializar Isar en el Isolate
      await _initializeIsar();

      // Inicializar notificaciones locales para alertas críticas autónomas
      await _initializeLocalNotifications();

      // Cargar alarmas activas
      await _loadActiveAlarms();

      // Configurar stream de posición
      await _setupPositionStream();

      debugPrint(
          '[TASK_HANDLER] Inicialización completa. Monitoreando ${_activeAlarms.length} alarmas');
    } catch (e) {
      debugPrint('[TASK_HANDLER] Error en onStart: $e');
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Este método se llama cada 5 segundos (configurado en main.dart)
    _reloadAlarmsIfNeeded();
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('[TASK_HANDLER] onDestroy llamado');
    await _positionSubscription?.cancel();
    await _isar?.close();
  }

  @override
  void onNotificationButtonPressed(String id) {
    debugPrint('[TASK_HANDLER] Botón de notificación presionado: $id');
  }

  @override
  void onNotificationPressed() {
    debugPrint('[TASK_HANDLER] Notificación presionada');
    FlutterForegroundTask.launchApp('/');
  }

  /// Inicializa las notificaciones locales dentro del Isolate
  Future<void> _initializeLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false, // Ya solicitados en main
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    debugPrint(
        '[TASK_HANDLER] Notificaciones locales inicializadas en Isolate');
  }

  /// Inicializa Isar en el Isolate
  Future<void> _initializeIsar() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [AlarmModelSchema],
        directory: dir.path,
        inspector: false,
      );
      debugPrint('[TASK_HANDLER] Isar inicializado en: ${dir.path}');
    } catch (e) {
      debugPrint('[TASK_HANDLER] Error al inicializar Isar: $e');
      rethrow;
    }
  }

  /// Carga las alarmas activas desde Isar
  Future<void> _loadActiveAlarms() async {
    if (_isar == null) return;

    try {
      final models =
          await _isar!.alarmModels.filter().isActiveEqualTo(true).findAll();
      _activeAlarms = models.cast<Alarm>().toList();
      debugPrint(
          '[TASK_HANDLER] Cargadas ${_activeAlarms.length} alarmas activas');
    } catch (e) {
      debugPrint('[TASK_HANDLER] Error al cargar alarmas: $e');
    }
  }

  /// Recarga alarmas periódicamente
  Future<void> _reloadAlarmsIfNeeded() async {
    await _loadActiveAlarms();

    // Actualizar notificación con el estado actual
    if (_lastPosition != null && _activeAlarms.isNotEmpty) {
      _updateNotificationWithNearestAlarm(_lastPosition!);
    }
  }

  /// Configura el stream de posición
  Future<void> _setupPositionStream() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualizar cada 10 metros
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      _onPositionUpdate,
      onError: (error) {
        debugPrint('[TASK_HANDLER] Error en stream de posición: $error');
      },
    );

    debugPrint('[TASK_HANDLER] Stream de posición configurado');
  }

  /// Maneja actualizaciones de posición
  void _onPositionUpdate(Position position) {
    _lastPosition = position;

    if (_activeAlarms.isEmpty) {
      // debugPrint('[TASK_HANDLER] No hay alarmas activas para monitorear');
      return;
    }

    debugPrint(
        '[TASK_HANDLER] Posición: (${position.latitude}, ${position.longitude}), '
        'Velocidad: ${position.speed.toStringAsFixed(2)} m/s');

    // Calcular distancias a todas las alarmas
    Alarm? nearestAlarm;
    double nearestDistance = double.infinity;

    for (final alarm in _activeAlarms) {
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        alarm.latitude,
        alarm.longitude,
      );

      debugPrint(
          '[TASK_HANDLER] Distancia a "${alarm.label}": ${distance.toStringAsFixed(2)}m');

      // Actualizar alarma más cercana
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestAlarm = alarm;
      }

      // Verificar si está dentro del radio
      if (distance <= alarm.radius) {
        debugPrint(
            '[TASK_HANDLER] ¡ALARMA DISPARADA! "${alarm.label}" - Distancia: ${distance.toStringAsFixed(2)}m');
        _triggerAlarm(alarm.id, distance);
      }
    }

    // Actualizar notificación con la alarma más cercana
    if (nearestAlarm != null) {
      _updateNotificationWithNearestAlarm(
          position, nearestAlarm, nearestDistance);
    }

    // Enviar datos de wake lock (velocidad y distancia más cercana)
    _sendWakeLockData(position.speed, nearestDistance);
  }

  /// Dispara una alarma enviando el evento al proceso principal y lanzando notificación crítica
  void _triggerAlarm(String alarmId, double distance) {
    // 1. Enviar datos al proceso principal para actualizar UI (si está viva)
    FlutterForegroundTask.sendDataToMain({
      'type': 'alarm_triggered',
      'alarmId': alarmId,
      'distance': distance,
    });

    // 2. Disparar alerta crítica autónoma directamente desde el Isolate
    final alarm = _activeAlarms.firstWhere(
      (a) => a.id == alarmId,
      orElse: () => AlarmModel(
          id: alarmId,
          label: 'Alarma',
          latitude: 0,
          longitude: 0,
          radius: 0,
          createdAt: DateTime.now()),
    );

    _triggerCriticalNotification(alarm, distance);
  }

  Future<void> _triggerCriticalNotification(
      Alarm alarm, double distance) async {
    try {
      await _localNotifications.show(
        alarm.id.hashCode,
        '¡Llegaste a tu destino!',
        'Estás en ${alarm.label} (Radio: ${alarm.radius}m)',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_channel_critical', // ID coincidente con el creado en NotificationServiceImpl
            'Alarmas de Destino (Críticas)',
            channelDescription:
                'Notificaciones de pantalla completa para llegada a destino',
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
            visibility: NotificationVisibility.public,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            category: AndroidNotificationCategory.alarm,
            playSound: true,
            enableVibration: true,
            // sound: RawResourceAndroidNotificationSound('alarm'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
        payload: alarm.id,
      );
      debugPrint(
          '[TASK_HANDLER] Alerta crítica disparada autónomamente para: ${alarm.label}');
    } catch (e) {
      debugPrint('[TASK_HANDLER] Error al disparar alerta crítica: $e');
    }
  }

  /// Envía datos para gestión de wake lock
  void _sendWakeLockData(double speed, double nearestDistance) {
    FlutterForegroundTask.sendDataToMain({
      'type': 'wake_lock_data',
      'speed': speed,
      'nearestDistance': nearestDistance,
    });
  }

  /// Actualiza la notificación persistente con información de la alarma más cercana
  void _updateNotificationWithNearestAlarm(
    Position position, [
    Alarm? nearestAlarm,
    double? distance,
  ]) {
    String title = 'GeoAlarm activo';
    String content = 'Monitoreando ${_activeAlarms.length} alarma(s)';

    if (nearestAlarm != null && distance != null) {
      content = '${nearestAlarm.label} - ${distance.toStringAsFixed(0)}m';
    }

    FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: content,
    );
  }

  /// Calcula la distancia entre dos coordenadas usando la fórmula de Haversine
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // Radio de la Tierra en metros
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
