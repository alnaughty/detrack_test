import 'package:detrack_test/services/location_services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Haversine Distance Calculator Tests', () {
    test('Identical coordinates return 0 distance', () {
      final distance = LocationServices.calculateHaversineDistance(
        lat1: 1.265,
        lon1: 103.695,
        lat2: 1.265,
        lon2: 103.695,
      );
      expect(distance, closeTo(0.0, 0.001));
    });

    test('Distance between Singapore and London is calculated correctly', () {
      // Singapore Marina Bay: 1.2823, 103.8587
      // London Big Ben: 51.5007, -0.1246
      // Known distance is roughly 10,850 km (10,850,000 meters)
      final distance = LocationServices.calculateHaversineDistance(
        lat1: 1.2823,
        lon1: 103.8587,
        lat2: 51.5007,
        lon2: -0.1246,
      );

      // Allow for a small variance (0.5%) due to ellipsoidal vs spherical Earth models
      expect(distance / 1000.0, closeTo(10850.0, 50.0));
    });

    test('Short distances calculated correctly', () {
      // Singapore Point A: 1.265, 103.695
      // Singapore Point B: 1.266, 103.696
      // Known spherical distance is ~157.2 meters
      final distance = LocationServices.calculateHaversineDistance(
        lat1: 1.265,
        lon1: 103.695,
        lat2: 1.266,
        lon2: 103.696,
      );
      expect(distance, closeTo(157.2, 1.0));
    });
  });
}
