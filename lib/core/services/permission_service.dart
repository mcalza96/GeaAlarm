import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static Future<bool> requestAdvancedPermissions(BuildContext context) async {
    // 1. Inform the user why we need "Always" location
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos de Ubicación'),
        content: const Text(
          'Para despertarte incluso si la aplicación está cerrada o tu teléfono bloqueado, necesitamos el permiso de "Ubicación Siempre".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );

    if (proceed != true) return false;

    // 2. Request While in Use
    final whenInUse = await Permission.locationWhenInUse.request();
    if (whenInUse.isDenied) return false;

    // 3. Request Always
    final always = await Permission.locationAlways.request();
    if (always.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Atención: Sin el permiso "Siempre", la alarma no funcionará en segundo plano.',
          ),
        ),
      );
    }

    // 4. Request Notifications
    await Permission.notification.request();

    return always.isGranted;
  }
}
