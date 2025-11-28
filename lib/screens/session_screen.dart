import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../components/progress_path.dart';
import '../utils/time_utils.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  static const route = '/session';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Leave session?'),
                content: const Text('This will stop your current focus.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Stay')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Stop')),
                ],
              ),
            ) ??
            false;
      },
      child: Consumer<AppState>(builder: (context, app, _) {
        final progress = app.progressValue();
        final pseudoAltitude = (progress * 12000).round();
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFc8e6ff), Color(0xFF8ec5fc)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _FlightMapPainter(progress: progress),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text('Focus flight',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(
                        app.cinematic3dFlight ? '3D flight map engaged' : 'Flat flight map',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Colors.white70, letterSpacing: 0.3),
                      ),
                      const SizedBox(height: 16),
                      ProgressPath(
                        progress: progress,
                        size: 260,
                        enable3d: app.cinematic3dFlight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatDuration(app.remaining),
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        app.isOnBreak ? 'Break in progress' : 'Stay on course',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _HudItem(label: 'Altitude', value: '${pseudoAltitude}m'),
                            _HudItem(label: 'Course', value: app.isOnBreak ? 'Rest loop' : 'Focus arc'),
                            _HudItem(label: 'Status', value: app.isPaused ? 'Paused' : 'Cruising'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: app.isPaused ? app.resumeSession : app.pauseSession,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                child: Text(app.isPaused ? 'Resume' : 'Pause'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  app.stopSession(completed: false);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blueAccent,
                                ),
                                child: const Text('Stop'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _HudItem extends StatelessWidget {
  const _HudItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.white70, letterSpacing: 1.1)),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _FlightMapPainter extends CustomPainter {
  _FlightMapPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double spacing = 60;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      final double offsetY = sin((x / size.width * pi) + (progress * pi * 2)) * 12;
      canvas.drawPath(
        Path()
          ..moveTo(x, -spacing)
          ..quadraticBezierTo(x + spacing / 2, size.height / 2 + offsetY, x, size.height + spacing),
        gridPaint,
      );
    }

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      final double offsetX = cos((y / size.height * pi) + (progress * pi * 2)) * 14;
      canvas.drawPath(
        Path()
          ..moveTo(-spacing, y)
          ..quadraticBezierTo(size.width / 2 + offsetX, y + spacing / 2, size.width + spacing, y),
        gridPaint,
      );
    }

    final Paint glow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.blueAccent.withOpacity(0.12), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: 220));

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 220, glow);
  }

  @override
  bool shouldRepaint(covariant _FlightMapPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
