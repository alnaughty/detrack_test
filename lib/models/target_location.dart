class TargetLocation {
  final String id;
  final double latitude;
  final double longitude;

  TargetLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  factory TargetLocation.fromJson(Map<String, dynamic> json) {
    return TargetLocation(
      id: json['id'] as String,
      latitude: (json['target_lat'] as num).toDouble(),
      longitude: (json['target_lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_lat': latitude,
      'target_lng': longitude,
    };
  }
}
