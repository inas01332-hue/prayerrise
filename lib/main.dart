import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/dev_tools_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/realtime_screen.dart';
import 'app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: 'https://ejnckjrrvvcxlvzbmhvg.supabase.co',
    anonKey: 'sb_publishable_iVei5p_VFYxHNg6tjPOsFA_W95YVx7W',
  );
  runApp(const PrayerRiseApp());
}

class PrayerRiseApp extends StatelessWidget {
  const PrayerRiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PrayerRise',
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
      routes: {
        '/dev-tools': (_) => const DevToolsScreen(),
        '/auth': (_) => const AuthScreen(),
        '/realtime': (_) => const RealtimeScreen(),
      },
    );
  }
}