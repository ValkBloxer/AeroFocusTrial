import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../components/progress_path.dart';
import '../utils/time_utils.dart';

class BreakScreen extends StatelessWidget {
  const BreakScreen({super.key});

  static const route = '/break';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, app, _) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFd7f3e3), Color(0xFFb2dfdb)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text('Break glide',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.teal.shade800)),
                const SizedBox(height: 16),
                ProgressPath(progress: app.progressValue(), size: 240),
                const SizedBox(height: 12),
                Text(
                  formatDuration(app.remaining),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: Colors.teal.shade800),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.cloud, color: Colors.white70, size: 40),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: app.isPaused ? app.resumeSession : app.pauseSession,
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
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
                            backgroundColor: Colors.teal,
                            minimumSize: const Size.fromHeight(48),
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
    });
  }
}
