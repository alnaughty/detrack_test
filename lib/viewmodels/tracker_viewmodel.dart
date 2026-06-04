import 'dart:async';

import 'package:detrack_test/models/location_reading.dart';
import 'package:detrack_test/models/target_location.dart';
import 'package:detrack_test/services/location_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TrackerViewModel extends ChangeNotifier {
  final LocationServices _locationService;
  Timer? _timer;

  bool _isTracking = false;
  bool _isLoading = false;
  TargetLocation? _target;
  final List<LocationReading> _allReadings = [];
  int _filterLimit = 10; // Default limit
  String? _errorMessage;

  // Constructor with optional Dependency Injection for unit testing
  TrackerViewModel({LocationServices? locationService})
    : _locationService = locationService ?? LocationServices();

  // Public Getters
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  TargetLocation? get target => _target;
  int get filterLimit => _filterLimit;
  String? get errorMessage => _errorMessage;

  /// Exposes the list of readings limited to the selected filter limit N (most recent first).
  List<LocationReading> get readings =>
      _allReadings.take(_filterLimit).toList();

  /// Exposes the total count of captured readings.
  int get totalReadingsCount => _allReadings.length;

  /// Toggles tracking status on/off.
  Future<void> toggleTracking() async {
    if (_isTracking) {
      _stopTracking();
    } else {
      await _startTracking();
    }
  }

  /// Starts the target coordinate fetch and schedules a 5-second GPS capturing timer.
  Future<void> _startTracking() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Verify & Request Location Permissions
    final hasPermission = await _locationService.checkAndRequestPermissions();
    if (!hasPermission) {
      _errorMessage =
          'Location permissions are required to start tracking. Please check your system settings.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // 2. Fetch Mock Target Coordinates from API
      _target = await _locationService.fetchTargetLocation();
      _isTracking = true;
      _isLoading = false;
      notifyListeners();

      // 3. Capture initial reading immediately on start
      await _captureLocationAndCalculateDistance();

      // 4. Begin periodic tracking at a strict 5-second interval
      _timer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _captureLocationAndCalculateDistance(),
      );
    } catch (e) {
      _errorMessage = 'Failed to start tracking: $e';
      _isLoading = false;
      _target = null;
      notifyListeners();
    }
  }

  /// Stops tracking immediately, canceling the active timer.
  void _stopTracking() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    notifyListeners();
  }

  /// Retrieves the current device location, calculates distance to target, and inserts it.
  Future<void> _captureLocationAndCalculateDistance() async {
    if (_target == null) return;

    try {
      final Position position = await _locationService.getCurrentPosition();
      final double distance = LocationServices.calculateHaversineDistance(
        lat1: position.latitude,
        lon1: position.longitude,
        lat2: _target!.latitude,
        lon2: _target!.longitude,
      );

      final reading = LocationReading(
        timestamp: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        distance: distance,
      );

      // Insert at index 0 (newest reading is stored first)
      _allReadings.insert(0, reading);
      _errorMessage = null; // Clear any transient capture errors
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Location capture error: $e';
      notifyListeners();
    }
  }

  /// Sets the display limit N (e.g. 5, 10, 15, 20) and notifies the view.
  void setFilterLimit(int limit) {
    _filterLimit = limit;
    notifyListeners();
  }

  /// Clears all stored in-memory readings.
  void clearReadings() {
    _allReadings.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
