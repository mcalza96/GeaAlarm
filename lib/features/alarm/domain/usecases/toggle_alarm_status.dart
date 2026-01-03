import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_alarm_repository.dart';

@injectable
class ToggleAlarmStatus extends UseCase<void, String> {
  final IAlarmRepository repository;

  ToggleAlarmStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    try {
      await repository.toggleAlarmStatus(params);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
