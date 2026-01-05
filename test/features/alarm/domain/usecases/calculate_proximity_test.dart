import 'package:flutter_test/flutter_test.dart';
import 'package:geo_alarm/features/alarm/domain/usecases/calculate_proximity.dart';

void main() {
  final calculateProximity = CalculateProximity();

  group('CalculateProximity - Haversine Formula Tests', () {
    test('Should return true when location is inside the radius', () {
      // Near Obelisco, Buenos Aires
      const targetLat = -34.603722;
      const targetLng = -58.381592;

      // 100 meters away
      const currentLat = -34.603722;
      const currentLng = -58.381592 + 0.001; // Approx 90m

      const radius = 500.0;

      final result = calculateProximity(
        ProximityParams(
          alarmLat: targetLat,
          alarmLng: targetLng,
          currentLat: currentLat,
          currentLng: currentLng,
          radius: radius,
        ),
      );

      expect(result, isTrue);
    });

    test('Should return false when location is outside the radius', () {
      // Near Obelisco, Buenos Aires
      const targetLat = -34.603722;
      const targetLng = -58.381592;

      // ~2km away
      const currentLat = -34.623722;
      const currentLng = -58.381592;

      const radius = 500.0;

      final result = calculateProximity(
        ProximityParams(
          alarmLat: targetLat,
          alarmLng: targetLng,
          currentLat: currentLat,
          currentLng: currentLng,
          radius: radius,
        ),
      );

      expect(result, isFalse);
    });

    test('Should be exact at the boundary (~500m)', () {
      // Target
      const targetLat = 40.7128; // NYC
      const targetLng = -74.0060;

      // Exactly ~500m away (approximate degree diff)
      // 1 degree lat is ~111km. 0.0045 degree is ~500m
      const currentLat = 40.7128 + 0.0045;
      const currentLng = -74.0060;

      const radius = 505.0; // Slightly more to be safe with approx

      final result = calculateProximity(
        ProximityParams(
          alarmLat: targetLat,
          alarmLng: targetLng,
          currentLat: currentLat,
          currentLng: currentLng,
          radius: radius,
        ),
      );

      expect(result, isTrue);
    });
  });
}
