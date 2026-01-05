import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:injectable/injectable.dart';
import '../errors/failures.dart';
import 'i_location_service.dart';

@LazySingleton(as: ILocationService)
class LocationService implements ILocationService {
  @override
  Future<Either<Failure, Position>> getCurrentPosition() async {
    try {
      // Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
            LocationFailure('Los servicios de ubicación están deshabilitados'));
      }

      // Verificar permisos
      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return const Left(LocationFailure('Permisos de ubicación denegados'));
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        return const Left(LocationFailure(
            'Los permisos de ubicación están permanentemente denegados'));
      }

      // Obtener la posición actual
      final geoPosition = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );

      return Right(Position(
        latitude: geoPosition.latitude,
        longitude: geoPosition.longitude,
      ));
    } catch (e) {
      return Left(
          LocationFailure('Error al obtener la ubicación: ${e.toString()}'));
    }
  }

  @override
  Stream<Position> getPositionStream() {
    return geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((geoPosition) => Position(
          latitude: geoPosition.latitude,
          longitude: geoPosition.longitude,
        ));
  }
}
