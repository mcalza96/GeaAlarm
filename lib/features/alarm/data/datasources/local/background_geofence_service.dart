import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:geo_alarm/features/alarm/domain/entities/alarm.dart';
import 'package:geo_alarm/features/alarm/domain/repositories/i_geofence_service.dart';

@LazySingleton(as: IGeofenceService)
class BackgroundGeofenceService implements IGeofenceService {
  final _controller = StreamController<String>.broadcast();
  final Map<String, StreamSubscription<Position>> _activeGeofences = {};

  @override
  Stream<String> get onGeofenceTriggered => _controller.stream;

  @override
  Future<void> registerGeofence(Alarm alarm) async {
    // Cancelar geofence existente si hay uno
    await removeGeofence(alarm.id);

    // Configurar el stream de posición
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualizar cada 10 metros
    );

    // Escuchar cambios de posición
    final subscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        alarm.latitude,
        alarm.longitude,
      );

      // Si está dentro del radio, disparar la alarma
      if (distance <= alarm.radius) {
        _controller.add(alarm.id);
      }
    });

    _activeGeofences[alarm.id] = subscription;
  }

  @override
  Future<void> removeGeofence(String id) async {
    final subscription = _activeGeofences.remove(id);
    await subscription?.cancel();
  }

  /// Calcula la distancia entre dos coordenadas usando la fórmula de Haversine
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // Radio de la Tierra en metros
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
