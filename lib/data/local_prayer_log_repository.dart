import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'prayer_log_repository.dart';

/// On-device implementation of [PrayerLogRepository], backed by
/// `shared_preferences`. Logs are stored as a single JSON-encoded map of
/// `yyyy-MM-dd` -> rounds-completed-that-day.
class LocalPrayerLogRepository implements PrayerLogRepository {
  static const _logsKey = 'beadly_daily_logs_v1';

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Future<Map<String, int>> getAllLogs() async {
    final prefs = await SharedPreferences.getInstance();
    // Picks up rounds logged by the Android screen-off counting service,
    // which writes to this same SharedPreferences file from native code.
    await prefs.reload();
    final raw = prefs.getString(_logsKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  @override
  Future<void> logRound(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getAllLogs();
    final key = dateKey(date);
    logs[key] = (logs[key] ?? 0) + 1;
    await prefs.setString(_logsKey, jsonEncode(logs));
  }
}
