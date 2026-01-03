import '../entities/alarm.dart';

abstract class IGeofenceService {
  Future<void> registerGeofence(Alarm alarm);
  Future<void> removeGeofence(String id);
  Stream<String> get onGeofenceTriggered;
}
