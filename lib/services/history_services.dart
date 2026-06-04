import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_reading.dart';

class HistoryService {
  static const String _storageKey = 'location_readings_history';
  final SharedPreferences _prefs;
  HistoryService(this._prefs);

  /// Loads saved readings from local persistence.
  List<LocationReading> loadReadings() {
    final String? jsonStr = _prefs.getString(_storageKey);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded
          .map((json) => LocationReading.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists the list of readings to local storage.
  Future<void> saveReadings(List<LocationReading> readings) async {
    final List<Map<String, dynamic>> jsonList = readings
        .map((r) => r.toJson())
        .toList();
    await _prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Clears persisted readings.
  Future<void> clearReadings() async {
    await _prefs.remove(_storageKey);
  }
}
