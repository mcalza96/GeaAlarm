abstract class INotificationService {
  Future<void> init();
  Future<void> showAlarmNotification({
    required String id,
    required String title,
    required String body,
  });
  Future<void> cancelNotification(int id);
}
