abstract class IVibrationService {
  /// Inicia el patrón de vibración de la alarma
  Future<void> vibrateAlarmPattern();

  /// Detiene cualquier vibración activa
  Future<void> stop();
}
