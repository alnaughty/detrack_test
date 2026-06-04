import 'dart:convert';
import 'dart:math';

import 'package:detrack_test/models/target_location.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationServices {
  final http.Client _client;
  static const String defaultTargetUrl =
      'https://httpbin.org/base64/eyJpZCI6IjAwMSIsInRhcmdldF9sYXQiOjEuMjY1LCJ0YXJnZXRfbG5nIjoxMDMuNjk1fQ==';

  LocationServices({http.Client? client}) : _client = client ?? http.Client();

  Future<TargetLocation> fetchTargetLocation({
    String url = defaultTargetUrl,
  }) async {
    final random = Random();
    final double offsetLat = (random.nextDouble() - 0.5) * 0.1;
    final double offsetLng = (random.nextDouble() - 0.5) * 0.1;

    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final baseTarget = TargetLocation.fromJson(data);
        return TargetLocation(
          id: baseTarget.id,
          latitude: baseTarget.latitude + offsetLat,
          longitude: baseTarget.longitude + offsetLng,
        );
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (_) {
      try {
        final String jsonString = await rootBundle.loadString(
          'assets/mock_target.json',
        );
        final Map<String, dynamic> data = jsonDecode(jsonString);
        final baseTarget = TargetLocation.fromJson(data);
        return TargetLocation(
          id: baseTarget.id,
          latitude: baseTarget.latitude + offsetLat,
          longitude: baseTarget.longitude + offsetLng,
        );
      } catch (assetError) {
        return TargetLocation(
          id: '001_failsafe',
          latitude: 1.265 + offsetLat,
          longitude: 103.695 + offsetLng,
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
