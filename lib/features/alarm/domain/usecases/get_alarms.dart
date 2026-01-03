import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/alarm.dart';
import '../repositories/i_alarm_repository.dart';

@injectable
class GetAlarms extends UseCase<List<Alarm>, NoParams> {
  final IAlarmRepository repository;

  GetAlarms(this.repository);

  @override
  Future<Either<Failure, List<Alarm>>> call(NoParams params) async {
    try {
      final alarms = await repository.getAlarms();
      return Right(alarms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
