import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:vibration/vibration.dart';

import 'i_vibration_service.dart';

@LazySingleton(as: IVibrationService)
class VibrationServiceImpl implements IVibrationService {
  @override
  Future<void> vibrateAlarmPattern() async {
    try {
      if (await Vibration.hasVibrator()) {
        // Patrón: esperar 0ms, vibrar 1000ms, esperar 500ms, vibrar 1000ms...
        // repeat: 0 => repetir desde el inicio (bucle infinito hasta cancel)
        Vibration.vibrate(pattern: [0, 1000, 500, 1000], repeat: 0);
        debugPrint('[VIBRATION] Patrón de alarma iniciado');
      }
    } catch (e) {
      debugPrint('[VIBRATION] Error al iniciar vibración: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      Vibration.cancel();
      debugPrint('[VIBRATION] Vibración detenida');
    } catch (e) {
      debugPrint('[VIBRATION] Error al detener vibración: $e');
    }
  }
}
