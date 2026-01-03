import 'dart:math' as math;
import 'package:injectable/injectable.dart';

class ProximityParams {
  final double currentLat;
  final double currentLng;
  final double alarmLat;
  final double alarmLng;
  final double radius;

  ProximityParams({
    required this.currentLat,
    required this.currentLng,
    required this.alarmLat,
    required this.alarmLng,
    required this.radius,
  });
}

@injectable
class CalculateProximity {
  bool call(ProximityParams params) {
    const double earthRadius = 6371000; // meters
    
    final lat1 = params.currentLat * math.pi / 180;
    final lat2 = params.alarmLat * math.pi / 180;
    final lon1 = params.currentLng * math.pi / 180;
    final lon2 = params.alarmLng * math.pi / 180;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = earthRadius * c;

    return distance <= params.radius;
  }
}
