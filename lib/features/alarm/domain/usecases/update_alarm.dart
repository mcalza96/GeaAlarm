import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/alarm.dart';
import '../repositories/i_alarm_repository.dart';

@injectable
class UpdateAlarm extends UseCase<void, Alarm> {
  final IAlarmRepository repository;

  UpdateAlarm(this.repository);

  @override
  Future<Either<Failure, void>> call(Alarm params) async {
    try {
      await repository.updateAlarm(params);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
