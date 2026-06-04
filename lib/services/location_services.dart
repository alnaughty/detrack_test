import 'dart:convert';
import 'dart:math';

import 'package:detrack_test/models/target_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationServices {
  final http.Client _client;
  static const String defaultTargetUrl = 'https://httpbin.org/base64';

  LocationServices({http.Client? client}) : _client = client ?? http.Client();

  Map<String, dynamic> _generateRandomData() {
    final random = Random();
    return {
      'id': '001',
      'target_lat': 1.265 + (random.nextDouble() - 0.5) * 0.1,
      'target_lng': 103.695 + (random.nextDouble() - 0.5) * 0.1,
    };
  }

  Future<TargetLocation> fetchTargetLocation() async {
    final rawPayload = _generateRandomData();
    final String jsonStr = jsonEncode(rawPayload);
    final String base64Payload = base64.encode(utf8.encode(jsonStr));
    final String url = '$defaultTargetUrl/$base64Payload';
    debugPrint('Generated URL for target fetch: $url');
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 3));
      debugPrint(response.body + response.statusCode.toString());
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TargetLocation.fromJson(data);
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      try {
        debugPrint(
          'Network request failed : $e, attempting to load target from local asset...',
        );
        // First fallback: Load from local mock target JSON asset (offline-first capability)
        final String jsonString = await rootBundle.loadString(
          'assets/mock_target.json',
        );
        final Map<String, dynamic> data = jsonDecode(jsonString);
        return TargetLocation.fromJson(data);
      } catch (assetError) {
        debugPrint('Asset loading failed: $assetError');
        // Second fallback: Hardcoded failsafe (used when running pure unit tests outside Flutter environment)
        return TargetLocation(
          id: '001_failsafe',
          latitude: rawPayload['target_lat']!,
          longitude: rawPayload['target_lng']!,
        );
      }
    }
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static double calculateHaversineDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371000.0; // Earth's radius in meters
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180.0;
  }
}
