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

  factory LocationReading.fromJson(Map<String, dynamic> json) {
    return LocationReading(
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
    };
  }
}
