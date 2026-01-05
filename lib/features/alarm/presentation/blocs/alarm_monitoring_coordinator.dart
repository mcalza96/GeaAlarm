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
    geofenceService.onGeofenceTriggered.listen((alarmId) async {
      final alarms = await alarmRepository.getAlarms();
      final alarm = alarms.firstWhere((a) => a.id == alarmId);

      await notificationService.showAlarmNotification(
        id: alarm.id,
        title: '¡Llegaste a tu destino!',
        body: 'Has entrado en el radio de: ${alarm.label}',
      );

      await audioService.playAlarmLoop();
    });
  }

  Future<void> stopAlarm() async {
    await audioService.stopAlarm();
  }
}
