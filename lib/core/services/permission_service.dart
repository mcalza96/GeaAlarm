import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  static Future<bool> requestAdvancedPermissions(BuildContext context) async {
    // 1. Inform the user why we need "Always" location and critical alerts
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos Críticos'),
        content: const Text(
          'GeoAlarm necesita acceso total a tu ubicación y notificaciones para despertarte a tiempo.\n\n'
          'Pediremos:\n'
          '1. Notificaciones (para avisarte).\n'
          '2. Ubicación "Siempre" (para medir mientras duermes).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (proceed != true) return false;

    // 2. Request Notifications (Android 13+)
    final notifications = await Permission.notification.request();
    if (notifications.isPermanentlyDenied) {
      if (context.mounted) _showSettingsDialog(context, 'Notificaciones');
      return false;
    }

    // 3. Request Exact Alarms (Android 12+)
    // Algunos dispositivos no soportan este permiso o lo conceden implícitamente
    if (await Permission.scheduleExactAlarm.status.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    // 4. Request Location Sequence
    final whenInUse = await Permission.locationWhenInUse.request();
    if (whenInUse.isDenied) return false;

    final always = await Permission.locationAlways.request();
    if (always.isDenied) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Atención: Sin el permiso "Siempre", la alarma fallará si bloqueas el teléfono.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }

    // 5. Verify GPS Service is Enabled
    final isGpsOn = await Geolocator.isLocationServiceEnabled();
    if (!isGpsOn) {
      if (!context.mounted) return false;
      bool? openGps = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('GPS Desactivado'),
          content:
              const Text('Tu ubicación está apagada. Actívala para continuar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Activar'),
            ),
          ],
        ),
      );
      if (openGps == true) {
        await Geolocator.openLocationSettings();
      }
    }

    // Retorna true si tenemos los permisos mínimos vitales (Notif + Always o Warning)
    // Consideramos éxito si tenemos Location (al menos InUse) y Notificaciones.
    return notifications.isGranted && (whenInUse.isGranted || always.isGranted);
  }

  static void _showSettingsDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Permiso Requerido: $permissionName'),
        content: Text(
            'Por favor habilita $permissionName en la configuración de la app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () => openAppSettings(),
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  /// Solicita al usuario que desactive la optimización de batería para la app.
  /// Esto es crítico en Android 12+ para que el foreground service funcione correctamente.
  static Future<bool> requestBatteryOptimizationExemption(
      BuildContext context) async {
    // Verificar si ya está en la lista blanca
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) {
      debugPrint('[PERMISSION] Ya tiene exención de optimización de batería');
      return true;
    }

    // Mostrar diálogo explicativo
    if (!context.mounted) return false;
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sistema de Ahorro de Batería'),
        content: const Text(
          'Tu teléfono puede apagar GeoAlarm para ahorrar batería.\n\n'
          'Para evitar que la alarma falle, por favor selecciona "Sin restricciones" o "No optimizar" en la siguiente pantalla.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Configurar'),
          ),
        ],
      ),
    );

    if (proceed != true) return false;

    // Solicitar el permiso (abre el menú del sistema)
    final result = await Permission.ignoreBatteryOptimizations.request();

    // Verificamos de nuevo tras volver
    if (await Permission.ignoreBatteryOptimizations.status.isDenied &&
        context.mounted) {
      // Opcional: Mostrar snackbar
    }

    return result.isGranted;
  }
}
