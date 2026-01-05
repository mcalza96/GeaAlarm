import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import 'i_notification_service.dart';

@LazySingleton(as: INotificationService)
class NotificationServiceImpl implements INotificationService {
  final _notifications = FlutterLocalNotificationsPlugin();
  final _actionStreamController = StreamController<String>.broadcast();

  @override
  Stream<String> get onNotificationAction => _actionStreamController.stream;

  @override
  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == 'action_stop_alarm' &&
            response.payload != null) {
          _actionStreamController.add(response.payload!);
        }
      },
    );
  }

  @override
  Future<void> showAlarmNotification({
    required String id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel_critical', // ID de canal diferente para alertas críticas
          'Alarmas de Destino (Críticas)',
          channelDescription:
              'Notificaciones de pantalla completa para llegada a destino',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true, // Habilita Full Screen Intent
          visibility: NotificationVisibility.public, // Visible en bloqueo
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          playSound: true,
          enableVibration: true,
          actions: [
            AndroidNotificationAction(
              'action_stop_alarm',
              'DETENER ALARMA',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
          // sound: RawResourceAndroidNotificationSound('alarm'),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'alarm.aiff',
          interruptionLevel: InterruptionLevel.critical, // Alerta crítica iOS
        ),
      ),
      payload: id,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
