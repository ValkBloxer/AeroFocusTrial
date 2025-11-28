import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_log.dart';

class StorageService {
  static const _sessionKey = 'sessions';
  static const _prefsKey = 'user_prefs';
  static const _streakKey = 'streak';
  static const _lastSessionDayKey = 'last_session_day';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<SessionLog>> loadSessions() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_sessionKey) ?? <String>[];
    return list.map(SessionLog.fromJson).toList();
  }

  Future<void> saveSessions(List<SessionLog> sessions) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      _sessionKey,
      sessions.map((s) => s.toJson()).toList(),
    );
  }

  Future<Map<String, dynamic>> loadUserPrefs() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveUserPrefs(Map<String, dynamic> prefsMap) async {
    final prefs = await _prefs;
    await prefs.setString(_prefsKey, jsonEncode(prefsMap));
  }

  Future<int> loadStreak() async {
    final prefs = await _prefs;
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> saveStreak(int streak) async {
    final prefs = await _prefs;
    await prefs.setInt(_streakKey, streak);
  }

  Future<DateTime?> loadLastSessionDay() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_lastSessionDayKey);
    return raw == null ? null : DateTime.parse(raw);
  }

  Future<void> saveLastSessionDay(DateTime date) async {
    final prefs = await _prefs;
    await prefs.setString(_lastSessionDayKey, date.toIso8601String());
  }

  Future<File> exportData({required List<SessionLog> sessions}) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/aerofocus_backup.json');
    final payload = {
      'sessions': sessions.map((s) => s.toMap()).toList(),
    };
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }
}
