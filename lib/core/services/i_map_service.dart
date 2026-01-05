import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class IMapService {
  Future<Either<Failure, String>> getAddressFromCoords(double lat, double lng);
  Future<Either<Failure, List<double>>> getCoordsFromAddress(String address);
}
