class LocationReading {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double distance; // in meters

  LocationReading({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });
}
