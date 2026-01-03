import 'package:injectable/injectable.dart';
import '../../domain/repositories/i_alarm_repository.dart';
import '../../domain/repositories/i_geofence_service.dart';

@LazySingleton()
class BootAlarmReactivator {
  final IAlarmRepository alarmRepository;
  final IGeofenceService geofenceService;

  BootAlarmReactivator({
    required this.alarmRepository,
    required this.geofenceService,
  });

  Future<void> reactivateActiveAlarms() async {
    final alarms = await alarmRepository.getAlarms();
    for (final alarm in alarms) {
      if (alarm.isActive) {
        await geofenceService.registerGeofence(alarm);
      }
    }
  }
}
