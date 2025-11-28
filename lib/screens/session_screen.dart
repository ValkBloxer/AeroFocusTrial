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
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFc8e6ff), Color(0xFF8ec5fc)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text('Focus flight',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 16),
                  ProgressPath(progress: app.progressValue(), size: 260),
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
          ),
        );
      }),
    );
  }
}
