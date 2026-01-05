import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:geo_alarm/features/alarm/domain/repositories/i_geofence_service.dart';
import 'package:geo_alarm/core/services/i_audio_service.dart';
import 'package:geo_alarm/core/services/i_notification_service.dart';
import 'package:geo_alarm/core/services/i_vibration_service.dart';
import 'package:geo_alarm/features/alarm/domain/repositories/i_alarm_repository.dart';

@LazySingleton()
class AlarmMonitoringCoordinator {
  final IGeofenceService geofenceService;
  final IAudioService audioService;
  final INotificationService notificationService;
  final IVibrationService vibrationService;
  final IAlarmRepository alarmRepository;

  AlarmMonitoringCoordinator({
    required this.geofenceService,
    required this.audioService,
    required this.notificationService,
    required this.vibrationService,
    required this.alarmRepository,
  });

  void init() {
    debugPrint('[COORDINATOR] Inicializando AlarmMonitoringCoordinator...');

    // Escuchar disparos de geofence
    geofenceService.onGeofenceTriggered.listen((alarmId) async {
      debugPrint('[COORDINATOR] ¡Geofence disparado! AlarmId: $alarmId');

      try {
        final alarms = await alarmRepository.getAlarms();
        final alarm = alarms.firstWhere((a) => a.id == alarmId);

        debugPrint('[COORDINATOR] Mostrando notificación para: ${alarm.label}');
        await notificationService.showAlarmNotification(
          id: alarm.id,
          title: '¡Llegaste a tu destino!',
          body: 'Has entrado en el radio de: ${alarm.label}',
        );

        debugPrint('[COORDINATOR] Reproduciendo sonido y vibración...');
        await audioService.playAlarmLoop();
        await vibrationService.vibrateAlarmPattern();
      } catch (e) {
        debugPrint('[COORDINATOR] ERROR: $e');
      }
    });

    // Escuchar acciones de notificación (botón Detener)
    notificationService.onNotificationAction.listen((alarmId) {
      debugPrint('[COORDINATOR] Acción de detener recibida para: $alarmId');
      stopAlarm(alarmId);
    });
  }

  Future<void> stopAlarm(String alarmId) async {
    debugPrint('[COORDINATOR] Deteniendo alarma: $alarmId');

    // 1. Detener audio y vibración
    await Future.wait([
      audioService.stopAlarm(),
      vibrationService.stop(),
    ]);

    // 2. Cerrar notificación
    await notificationService.cancelNotification(alarmId.hashCode);

    // 3. Desactivar alarma en BD
    try {
      await alarmRepository.toggleAlarmStatus(alarmId);
    } catch (e) {
      debugPrint('[COORDINATOR] Error al desactivar alarma en BD: $e');
    }

    // 4. Remover geocerca activa
    try {
      final alarms = await alarmRepository.getAlarms();
      final alarm = alarms.firstWhere(
        (a) => a.id == alarmId,
        orElse: () => throw Exception('Alarma no encontrada'),
      );

      await geofenceService.removeGeofence(alarm.id);
    } catch (e) {
      debugPrint('[COORDINATOR] Error al remover geocerca: $e');
    }
  }
}
