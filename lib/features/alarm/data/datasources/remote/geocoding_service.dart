import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/i_map_service.dart';

@LazySingleton(as: IMapService)
class GeocodingService implements IMapService {
  @override
  Future<Either<Failure, String>> getAddressFromCoords(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return Right('${place.street}, ${place.locality}, ${place.country}');
      }
      return const Left(ServerFailure('No se encontró una dirección para estas coordenadas.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
