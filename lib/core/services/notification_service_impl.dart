import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import 'i_notification_service.dart';

@LazySingleton(as: INotificationService)
class NotificationServiceImpl implements INotificationService {
  final _notifications = FlutterLocalNotificationsPlugin();

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
    );
  }

  @override
  Future<void> showAlarmNotification({
    required String id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'alarm_channel',
      'Alarmas de Destino',
      channelDescription:
          'Notificaciones para despertarte al llegar a tu destino',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      // sound: RawResourceAndroidNotificationSound('alarm'),
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm.aiff',
      interruptionLevel: InterruptionLevel.critical,
    );

    await _notifications.show(
      id.hashCode,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
      payload: id,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
