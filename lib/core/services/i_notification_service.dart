import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class INotificationService {
  Future<Either<Failure, void>> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  Future<void> cancelNotification(int id);
}
