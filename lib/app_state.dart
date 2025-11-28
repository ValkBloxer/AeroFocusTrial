import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'models/session_log.dart';
import 'services/storage_service.dart';
import 'utils/motivation.dart';

class AppState extends ChangeNotifier {
  AppState(this._storage, this._notifications);

  final StorageService _storage;
  final FlutterLocalNotificationsPlugin _notifications;

  List<SessionLog> _sessions = [];
  int _streak = 0;
  Duration focusDuration = const Duration(minutes: 25);
  Duration breakDuration = const Duration(minutes: 5);
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  ThemeMode themeMode = ThemeMode.system;

  Timer? _timer;
  DateTime? _sessionStart;
  Duration remaining = Duration.zero;
  bool isOnBreak = false;
  bool isPaused = false;

  List<SessionLog> get sessions => _sessions;
  int get streak => _streak;

  Future<void> initialize() async {
    _sessions = await _storage.loadSessions();
    _streak = await _storage.loadStreak();
    final prefs = await _storage.loadUserPrefs();
    if (prefs.isNotEmpty) {
      focusDuration = Duration(minutes: prefs['focus'] as int? ?? 25);
      breakDuration = Duration(minutes: prefs['break'] as int? ?? 5);
      soundEnabled = prefs['sound'] as bool? ?? true;
      vibrationEnabled = prefs['vibration'] as bool? ?? true;
      final theme = prefs['theme'] as String?;
      if (theme == 'dark') themeMode = ThemeMode.dark;
      if (theme == 'light') themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void updateTheme(ThemeMode mode) {
    themeMode = mode;
    _persistPrefs();
    notifyListeners();
  }

  void updateDurations({required int focusMinutes, required int breakMinutes}) {
    focusDuration = Duration(minutes: focusMinutes);
    breakDuration = Duration(minutes: breakMinutes);
    _persistPrefs();
    notifyListeners();
  }

  void toggleSound(bool value) {
    soundEnabled = value;
    _persistPrefs();
    notifyListeners();
  }

  void toggleVibration(bool value) {
    vibrationEnabled = value;
    _persistPrefs();
    notifyListeners();
  }

  Future<void> _persistPrefs() async {
    await _storage.saveUserPrefs({
      'focus': focusDuration.inMinutes,
      'break': breakDuration.inMinutes,
      'sound': soundEnabled,
      'vibration': vibrationEnabled,
      'theme': themeMode == ThemeMode.dark
          ? 'dark'
          : themeMode == ThemeMode.light
              ? 'light'
              : 'system',
    });
  }

  void startSession({Duration? customDuration, bool breakMode = false}) {
    _timer?.cancel();
    isOnBreak = breakMode;
    isPaused = false;
    remaining = customDuration ?? (breakMode ? breakDuration : focusDuration);
    _sessionStart = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void pauseSession() {
    if (_timer == null) return;
    _timer?.cancel();
    isPaused = true;
    notifyListeners();
  }

  void resumeSession() {
    if (!isPaused) return;
    isPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void stopSession({bool completed = false}) {
    _timer?.cancel();
    if (_sessionStart != null) {
      final elapsed = (customDuration() - remaining).inMinutes;
      _sessions.add(SessionLog(
        startTime: _sessionStart!,
        focusMinutes: isOnBreak ? 0 : max(elapsed, 0),
        breakMinutes: isOnBreak ? max(elapsed, 0) : 0,
        completed: completed,
      ));
      _updateStreak();
      _storage.saveSessions(_sessions);
    }
    remaining = Duration.zero;
    _sessionStart = null;
    isOnBreak = false;
    notifyListeners();
  }

  Duration customDuration() => isOnBreak ? breakDuration : focusDuration;

  void _tick() {
    if (remaining.inSeconds <= 1) {
      _notifyCompletion();
      stopSession(completed: true);
      if (!isOnBreak) {
        startSession(breakMode: true);
      }
      return;
    }
    remaining -= const Duration(seconds: 1);
    notifyListeners();
  }

  Future<void> _notifyCompletion() async {
    await _notifications.show(
      0,
      isOnBreak ? 'Break done' : 'Focus complete',
      Motivation.randomMessage(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'aerofocus_channel',
          'AeroFocus',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> _updateStreak() async {
    final today = DateTime.now();
    final lastDay = await _storage.loadLastSessionDay();
    final todayMinutes = _sessions
        .where((s) => _sameDay(s.startTime, today))
        .fold<int>(0, (sum, s) => sum + s.focusMinutes);
    if (todayMinutes < 1) return;

    if (lastDay == null) {
      _streak = 1;
    } else {
      final diff = today.difference(DateTime(lastDay.year, lastDay.month, lastDay.day)).inDays;
      if (diff == 0) {
        // same day, keep streak
      } else if (diff == 1) {
        _streak += 1;
      } else {
        _streak = 1;
      }
    }
    await _storage.saveLastSessionDay(today);
    await _storage.saveStreak(_streak);
    notifyListeners();
  }

  double progressValue() {
    if (_sessionStart == null || customDuration().inSeconds == 0) return 0;
    final elapsed = customDuration().inSeconds - remaining.inSeconds;
    return (elapsed / customDuration().inSeconds).clamp(0, 1);
  }

  Duration totalFocusTime() => Duration(
      minutes: _sessions.fold<int>(0, (sum, s) => sum + s.focusMinutes));

  int totalSessions() => _sessions.length;

  Map<DateTime, int> dailyTotals({int days = 7}) {
    final Map<DateTime, int> totals = {};
    for (final log in _sessions) {
      final day = DateTime(log.startTime.year, log.startTime.month, log.startTime.day);
      totals[day] = (totals[day] ?? 0) + log.focusMinutes;
    }
    final now = DateTime.now();
    return Map.fromEntries(List.generate(days, (i) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - i - 1));
      return MapEntry(day, totals[day] ?? 0);
    }));
  }

  Map<int, int> monthlyTotals(int months) {
    final now = DateTime.now();
    final Map<int, int> totals = {};
    for (final log in _sessions) {
      final key = log.startTime.month;
      if (log.startTime.year == now.year) {
        totals[key] = (totals[key] ?? 0) + log.focusMinutes;
      }
    }
    return Map.fromEntries(List.generate(months, (index) {
      final month = index + 1;
      return MapEntry(month, totals[month] ?? 0);
    }));
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
