import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/repositories/i_alarm_repository.dart';
import '../models/alarm_model.dart';

@LazySingleton(as: IAlarmRepository)
class IsarAlarmRepository implements IAlarmRepository {
  final Isar isar;

  IsarAlarmRepository(this.isar);

  @override
  Future<void> saveAlarm(Alarm alarm) async {
    final model = AlarmModel.fromEntity(alarm);
    await isar.writeTxn(() async {
      await isar.alarmModels.put(model);
    });
  }

  @override
  Future<void> updateAlarm(Alarm alarm) async {
    // Isar put performs an upsert, so basic logic is identical to save
    final model = AlarmModel.fromEntity(alarm);
    await isar.writeTxn(() async {
      await isar.alarmModels.put(model);
    });
  }
  // ... rest of methods will use await _db

  @override
  Future<void> deleteAlarm(String id) async {
    await isar.writeTxn(() async {
      await isar.alarmModels.delete(fastHash(id));
    });
  }

  @override
  Future<List<Alarm>> getAlarms() async {
    final models = await isar.alarmModels.where().findAll();
    return models.toList();
  }

  @override
  Future<void> toggleAlarmStatus(String id) async {
    await isar.writeTxn(() async {
      final alarm = await isar.alarmModels.get(fastHash(id));
      if (alarm != null) {
        final updated = AlarmModel(
          id: alarm.id,
          latitude: alarm.latitude,
          longitude: alarm.longitude,
          radius: alarm.radius,
          label: alarm.label,
          isActive: !alarm.isActive,
          createdAt: alarm.createdAt,
        );
        await isar.alarmModels.put(updated);
      }
    });
  }
}
