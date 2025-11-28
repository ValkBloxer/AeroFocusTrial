import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/break_screen.dart';
import 'screens/home_screen.dart';
import 'screens/session_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'services/storage_service.dart';

final _notifications = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _notifications.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  ));
  final storage = StorageService();
  final appState = AppState(storage, _notifications);
  await appState.initialize();
  runApp(ChangeNotifierProvider.value(value: appState, child: const AeroFocusApp()));
}

class AeroFocusApp extends StatelessWidget {
  const AeroFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, app, _) {
      return MaterialApp(
        title: 'AeroFocus',
        themeMode: app.themeMode,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          SessionScreen.route: (_) => const SessionScreen(),
          BreakScreen.route: (_) => const BreakScreen(),
          StatsScreen.route: (_) => const StatsScreen(),
          SettingsScreen.route: (_) => const SettingsScreen(),
        },
      );
    });
  }
}
