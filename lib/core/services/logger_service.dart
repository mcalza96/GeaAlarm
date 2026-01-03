import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';

abstract class ILoggerService {
  Future<void> log(String message);
  Future<String> getLogs();
  Future<void> clearLogs();
}

@LazySingleton(as: ILoggerService)
class LoggerService implements ILoggerService {
  Future<File> get _logFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/geoalarm_logs.txt');
  }

  @override
  Future<void> log(String message) async {
    final file = await _logFile;
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString(
      '[$timestamp] $message\n',
      mode: FileMode.append,
    );
    print('LOG: $message'); // Also print to console
  }

  @override
  Future<String> getLogs() async {
    try {
      final file = await _logFile;
      if (await file.exists()) {
        return await file.readAsString();
      }
      return 'No hay logs disponibles.';
    } catch (e) {
      return 'Error al leer logs: $e';
    }
  }

  @override
  Future<void> clearLogs() async {
    final file = await _logFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
