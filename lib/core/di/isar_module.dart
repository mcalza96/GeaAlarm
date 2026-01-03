import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../features/alarm/data/models/alarm_model.dart';
import 'package:path_provider/path_provider.dart';

@module
abstract class IsarModule {
  @preResolve
  @singleton
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [AlarmModelSchema],
      directory: dir.path,
    );
  }
}
