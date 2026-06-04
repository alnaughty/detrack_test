import 'package:detrack_test/models/target_location.dart';
import 'package:detrack_test/services/location_services.dart';
import 'package:detrack_test/viewmodels/tracker_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

class MockLocationService implements LocationServices {
  bool permissionGranted = true;
  bool fetchShouldFail = false;

  TargetLocation mockTarget = TargetLocation(
    id: 'test_target',
    latitude: 1.265,
    longitude: 103.695,
  );

  Position mockPosition = Position(
    latitude: 1.266,
    longitude: 103.696,
    timestamp: DateTime.now(),
    accuracy: 10.0,
    altitude: 10.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );

  @override
  Future<TargetLocation> fetchTargetLocation() async {
    if (fetchShouldFail) {
      // Simulate real service behavior of returning fallback target when API fails
      return TargetLocation(
        id: '001_fallback',
        latitude: 1.265,
        longitude: 103.695,
      );
    }
    return mockTarget;
  }

  @override
  Future<Position> getCurrentPosition() async {
    return mockPosition;
  }

  @override
  Future<bool> checkAndRequestPermissions() async {
    return permissionGranted;
  }
}

void main() {
  late MockLocationService mockService;
  late TrackerViewModel viewModel;

  setUp(() {
    mockService = MockLocationService();
    viewModel = TrackerViewModel(locationService: mockService);
  });

  group('TrackerViewModel Tests', () {
    test('Initial state is correct', () {
      expect(viewModel.isTracking, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.target, null);
      expect(viewModel.readings, isEmpty);
      expect(viewModel.filterLimit, 10);
      expect(viewModel.errorMessage, null);
    });

    test('Tracking fails when location permissions are denied', () async {
      mockService.permissionGranted = false;

      await viewModel.toggleTracking();

      expect(viewModel.isTracking, isFalse);
      expect(viewModel.errorMessage, contains('permissions are required'));
    });

    test(
      'Tracking starts, fetches target coordinates, and captures initial reading',
      () async {
        await viewModel.toggleTracking();

        expect(viewModel.isTracking, isTrue);
        expect(viewModel.target?.id, 'test_target');
        expect(viewModel.errorMessage, isNull);

        // Verification of immediate capture
        expect(viewModel.readings, hasLength(1));
        expect(viewModel.readings.first.latitude, 1.266);
        expect(viewModel.readings.first.longitude, 103.696);
        // Haversine calculation distance check
        expect(viewModel.readings.first.distance, closeTo(157.2, 1.0));
      },
    );

    test(
      'Tracking stops cancels scheduling and toggles isTracking state',
      () async {
        await viewModel.toggleTracking(); // Start
        expect(viewModel.isTracking, isTrue);

        await viewModel.toggleTracking(); // Stop
        expect(viewModel.isTracking, isFalse);
      },
    );

    test('Filter limits restrict returned readings list', () async {
      await viewModel.toggleTracking(); // Capture 1

      // Manually add more readings for testing limits
      viewModel.setFilterLimit(2);

      expect(viewModel.readings, hasLength(1));
    });

    test('Clearing history wipes stored readings', () async {
      await viewModel.toggleTracking(); // Capture 1
      expect(viewModel.readings, isNotEmpty);

      viewModel.clearReadings();
      expect(viewModel.readings, isEmpty);
    });

    test(
      'Handles API failure by gracefully falling back to default coordinates',
      () async {
        mockService.fetchShouldFail = true;

        await viewModel.toggleTracking();

        // Should succeed due to fallback target coordinates
        expect(viewModel.isTracking, isTrue);
        expect(viewModel.target?.id, '001_fallback');
        expect(viewModel.readings, hasLength(1));
      },
    );
  });
}
