import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/notification_service.dart'; // ✅ ADD THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ ADD

  tz.initializeTimeZones(); // 🔥 VERY IMPORTANT
  await NotificationService.init(); // 🔔 INIT NOTIFICATIONS

  runApp(const StudySphere());
}

class StudySphere extends StatelessWidget {
  const StudySphere({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // START SCREEN
      initialRoute: '/login',

      // ROUTES
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}