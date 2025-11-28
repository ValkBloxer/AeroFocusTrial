import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const route = '/settings';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final focusController = TextEditingController(text: app.focusDuration.inMinutes.toString());
    final breakController = TextEditingController(text: app.breakDuration.inMinutes.toString());
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {app.themeMode},
            onSelectionChanged: (set) => app.updateTheme(set.first),
          ),
          const SizedBox(height: 20),
          Text('Durations (minutes)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: focusController,
                  decoration: const InputDecoration(labelText: 'Focus'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: breakController,
                  decoration: const InputDecoration(labelText: 'Break'),
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  final focus = int.tryParse(focusController.text) ?? app.focusDuration.inMinutes;
                  final rest = int.tryParse(breakController.text) ?? app.breakDuration.inMinutes;
                  app.updateDurations(focusMinutes: focus, breakMinutes: rest);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            value: app.soundEnabled,
            onChanged: app.toggleSound,
            title: const Text('Sound alerts'),
          ),
          SwitchListTile(
            value: app.vibrationEnabled,
            onChanged: app.toggleVibration,
            title: const Text('Vibration'),
          ),
          SwitchListTile(
            value: app.cinematic3dFlight,
            onChanged: app.toggleCinematicFlight,
            title: const Text('Cinematic 3D flight path'),
            subtitle: const Text('Adds perspective and shading to the plane track'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              final file = await StorageService().exportData(sessions: app.sessions);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Backup saved to ${file.path}')),
                );
              }
            },
            icon: const Icon(Icons.download),
            label: const Text('Backup / Export'),
          ),
          const SizedBox(height: 20),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'AeroFocus is a lightweight focus companion inspired by playful flight. '
            'Sessions, stats, and streaks live on your device only.',
          ),
        ],
      ),
    );
  }
}
