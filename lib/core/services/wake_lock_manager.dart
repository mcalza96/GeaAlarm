import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Gestiona el wake lock de forma inteligente para minimizar el consumo de batería
/// mientras mantiene la confiabilidad del monitoreo de ubicación.
@LazySingleton()
class WakeLockManager {
  bool _isEnabled = false;

  /// Evalúa si el wake lock debe estar activo basándose en:
  /// 1. Velocidad del usuario (en movimiento)
  /// 2. Distancia a la alarma más cercana
  ///
  /// Criterios de activación:
  /// - Velocidad > 1 m/s (usuario en movimiento)
  /// - O distancia a alarma más cercana < 500m
  Future<void> evaluateWakeLock({
    required double speedMps,
    required double nearestAlarmDistanceMeters,
  }) async {
    final shouldEnable = speedMps > 1.0 || nearestAlarmDistanceMeters < 500;

    if (shouldEnable && !_isEnabled) {
      await _enableWakeLock();
      debugPrint(
          '[WAKE_LOCK] Activado - Velocidad: ${speedMps.toStringAsFixed(2)} m/s, '
          'Distancia más cercana: ${nearestAlarmDistanceMeters.toStringAsFixed(0)}m');
    } else if (!shouldEnable && _isEnabled) {
      await _disableWakeLock();
      debugPrint(
          '[WAKE_LOCK] Desactivado - Usuario estático y lejos de destinos');
    }
  }

  Future<void> _enableWakeLock() async {
    try {
      await WakelockPlus.enable();
      _isEnabled = true;
    } catch (e) {
      debugPrint('[WAKE_LOCK] Error al activar: $e');
    }
  }

  Future<void> _disableWakeLock() async {
    try {
      await WakelockPlus.disable();
      _isEnabled = false;
    } catch (e) {
      debugPrint('[WAKE_LOCK] Error al desactivar: $e');
    }
  }

  /// Fuerza la desactivación del wake lock (útil al detener todas las alarmas)
  Future<void> forceDisable() async {
    if (_isEnabled) {
      await _disableWakeLock();
      debugPrint('[WAKE_LOCK] Desactivación forzada');
    }
  }

  bool get isEnabled => _isEnabled;
}
