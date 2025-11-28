import 'dart:convert';

class SessionLog {
  final DateTime startTime;
  final int focusMinutes;
  final int breakMinutes;
  final bool completed;

  SessionLog({
    required this.startTime,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.completed,
  });

  Map<String, dynamic> toMap() => {
        'startTime': startTime.toIso8601String(),
        'focusMinutes': focusMinutes,
        'breakMinutes': breakMinutes,
        'completed': completed,
      };

  String toJson() => jsonEncode(toMap());

  factory SessionLog.fromMap(Map<String, dynamic> map) => SessionLog(
        startTime: DateTime.parse(map['startTime'] as String),
        focusMinutes: map['focusMinutes'] as int? ?? 0,
        breakMinutes: map['breakMinutes'] as int? ?? 0,
        completed: map['completed'] as bool? ?? false,
      );

  factory SessionLog.fromJson(String source) =>
      SessionLog.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
