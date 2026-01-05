import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:geo_alarm/features/alarm/domain/repositories/i_geofence_service.dart';
import 'package:geo_alarm/core/services/i_audio_service.dart';
import 'package:geo_alarm/core/services/i_notification_service.dart';
import 'package:geo_alarm/features/alarm/domain/repositories/i_alarm_repository.dart';

@LazySingleton()
class AlarmMonitoringCoordinator {
  final IGeofenceService geofenceService;
  final IAudioService audioService;
  final INotificationService notificationService;
  final IAlarmRepository alarmRepository;

  AlarmMonitoringCoordinator({
    required this.geofenceService,
    required this.audioService,
    required this.notificationService,
    required this.alarmRepository,
  });

  void init() {
    debugPrint('[COORDINATOR] Inicializando AlarmMonitoringCoordinator...');
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

        debugPrint('[COORDINATOR] Reproduciendo sonido de alarma...');
        await audioService.playAlarmLoop();
      } catch (e) {
        debugPrint('[COORDINATOR] ERROR: $e');
      }
    });
  }

  Future<void> stopAlarm() async {
    await audioService.stopAlarm();
  }
}
