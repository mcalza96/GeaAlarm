import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class ILocationService {
  Future<Either<Failure, Position>> getCurrentPosition();
  Stream<Position> getPositionStream();
}

class Position {
  final double latitude;
  final double longitude;

  Position({required this.latitude, required this.longitude});
}
