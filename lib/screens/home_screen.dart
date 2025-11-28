import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../components/progress_path.dart';
import '../components/stats_preview.dart';
import '../utils/motivation.dart';
import '../utils/time_utils.dart';
import 'session_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final todayMinutes = app.sessions
        .where((s) => s.startTime.day == DateTime.now().day &&
            s.startTime.month == DateTime.now().month &&
            s.startTime.year == DateTime.now().year)
        .fold<int>(0, (sum, s) => sum + s.focusMinutes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AeroFocus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.pushNamed(context, StatsScreen.route),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.route),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.shade50,
              Colors.blue.shade100.withOpacity(0.4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text('Stay light, keep gliding',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ProgressPath(
                progress: app.progressValue(),
                enable3d: app.cinematic3dFlight,
              ),
              const SizedBox(height: 12),
              Text(
                formatDuration(app.remaining == Duration.zero
                    ? app.focusDuration
                    : app.remaining),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: [15, 25, 45, 60].map((minutes) {
                  return ChoiceChip(
                    label: Text('$minutes min'),
                    selected: app.focusDuration.inMinutes == minutes,
                    onSelected: (_) =>
                        app.updateDurations(focusMinutes: minutes, breakMinutes: app.breakDuration.inMinutes),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  app.startSession();
                  Navigator.pushNamed(context, SessionScreen.route);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Start Session'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _showCustomTimer(context, app),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Custom Timer'),
              ),
              const SizedBox(height: 20),
              StatsPreview(todayMinutes: todayMinutes, streak: app.streak),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flight_takeoff, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Expanded(child: Text(Motivation.randomMessage())),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomTimer(BuildContext context, AppState app) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Custom minutes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 40',
                prefixIcon: Icon(Icons.timer),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final minutes = int.tryParse(controller.text);
                if (minutes != null && minutes > 0) {
                  app.startSession(customDuration: Duration(minutes: minutes));
                  Navigator.pop(context);
                  Navigator.pushNamed(context, SessionScreen.route);
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('Begin'),
            ),
          ],
        ),
      ),
    );
  }
}
