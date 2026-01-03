import '../entities/alarm.dart';

abstract class IAlarmRepository {
  Future<void> saveAlarm(Alarm alarm);
  Future<void> deleteAlarm(String id);
  Future<List<Alarm>> getAlarms();
  Future<void> toggleAlarmStatus(String id);
}
