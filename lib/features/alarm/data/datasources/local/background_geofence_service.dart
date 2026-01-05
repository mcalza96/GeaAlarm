import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geo_alarm/features/alarm/domain/entities/alarm.dart';
import 'package:geo_alarm/features/alarm/domain/repositories/i_geofence_service.dart';
import 'package:geo_alarm/core/services/wake_lock_manager.dart';
import 'background_task_handler.dart';

/// Implementación del servicio de geofencing usando foreground service
/// para garantizar ejecución resiliente en segundo plano.
@LazySingleton(as: IGeofenceService)
class BackgroundGeofenceService implements IGeofenceService {
  final WakeLockManager _wakeLockManager;
  final _controller = StreamController<String>.broadcast();
  final Set<String> _registeredAlarmIds = {};
  bool _isServiceRunning = false;

  BackgroundGeofenceService(this._wakeLockManager) {
    _initializeReceivePort();
  }

  @override
  Stream<String> get onGeofenceTriggered => _controller.stream;

  /// Inicializa el receptor de datos del Isolate
  void _initializeReceivePort() {
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
  }

  /// Callback que recibe datos del Isolate
  void _onTaskData(dynamic data) {
    if (data is Map) {
      final type = data['type'] as String?;

      if (type == 'alarm_triggered') {
        final alarmId = data['alarmId'] as String;
        final distance = data['distance'] as double;
        debugPrint(
            '[GEOFENCE_SERVICE] Alarma disparada desde Isolate: $alarmId (${distance.toStringAsFixed(2)}m)');
        _controller.add(alarmId);
      } else if (type == 'wake_lock_data') {
        final speed = data['speed'] as double;
        final nearestDistance = data['nearestDistance'] as double;
        _wakeLockManager.evaluateWakeLock(
          speedMps: speed,
          nearestAlarmDistanceMeters: nearestDistance,
        );
      }
    }
  }

  @override
  Future<void> registerGeofence(Alarm alarm) async {
    debugPrint(
        '[GEOFENCE_SERVICE] Registrando geocerca para alarma: ${alarm.label} (${alarm.id})');

    _registeredAlarmIds.add(alarm.id);

    // Iniciar el servicio de foreground si no está corriendo
    if (!_isServiceRunning) {
      await _startForegroundService();
    }

    debugPrint('[GEOFENCE_SERVICE] Geocerca registrada exitosamente');
  }

  @override
  Future<void> removeGeofence(String id) async {
    debugPrint('[GEOFENCE_SERVICE] Removiendo geocerca: $id');
    _registeredAlarmIds.remove(id);

    // Si no quedan alarmas, detener el servicio
    if (_registeredAlarmIds.isEmpty) {
      await _stopForegroundService();
    }
  }

  /// Inicia el servicio de foreground
  Future<void> _startForegroundService() async {
    if (_isServiceRunning) {
      debugPrint('[GEOFENCE_SERVICE] El servicio ya está corriendo');
      return;
    }

    try {
      // Verificar si el servicio puede iniciarse
      final isRunning = await FlutterForegroundTask.isRunningService;
      if (!isRunning) {
        await FlutterForegroundTask.startService(
          serviceId: 256,
          notificationTitle: 'GeoAlarm activo',
          notificationText: 'Monitoreando tus alarmas de ubicación',
          notificationIcon: null,
          notificationButtons: [
            const NotificationButton(id: 'stop', text: 'Detener'),
          ],
          callback: backgroundTaskHandler,
        );

        _isServiceRunning = true;
        debugPrint('[GEOFENCE_SERVICE] Servicio de foreground iniciado');
      } else {
        _isServiceRunning = true;
        debugPrint('[GEOFENCE_SERVICE] Servicio ya estaba corriendo');
      }
    } catch (e) {
      debugPrint('[GEOFENCE_SERVICE] Error al iniciar servicio: $e');
    }
  }

  /// Detiene el servicio de foreground
  Future<void> _stopForegroundService() async {
    if (!_isServiceRunning) {
      debugPrint('[GEOFENCE_SERVICE] El servicio no está corriendo');
      return;
    }

    try {
      await FlutterForegroundTask.stopService();
      _isServiceRunning = false;

      // Desactivar wake lock
      await _wakeLockManager.forceDisable();

      debugPrint('[GEOFENCE_SERVICE] Servicio de foreground detenido');
    } catch (e) {
      debugPrint('[GEOFENCE_SERVICE] Error al detener servicio: $e');
    }
  }

  /// Limpia recursos
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    _controller.close();
  }
}
