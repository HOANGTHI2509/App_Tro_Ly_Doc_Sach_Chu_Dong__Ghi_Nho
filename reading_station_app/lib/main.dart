import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reading_station_app/controllers/auth_controller.dart';
import 'package:reading_station_app/views/auth/login_screen.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:reading_station_app/views/main_screen.dart'; // From HEAD (We will keep our MainScreen)
// The remote imported features/library/library_page.dart, but our MainScreen is likely the current source of truth for navigation.
import 'package:reading_station_app/views/library/library_screen.dart';
import 'package:reading_station_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase correctly for Auth and Database
  await Supabase.initialize(
    url: 'https://qdkjnzevjwibyrfindvb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFka2puemV2andpYnlyZmluZHZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwMDA3MDYsImV4cCI6MjA4OTU3NjcwNn0.FUhHCzeB1msfrYx9YhklkplrSAIGMGMCV3hpNIhQU7o',
  );

  // Initialize Notification Service
  await NotificationService().init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trạm Đọc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFA6400), primary: const Color(0xFFFA6400)),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
        textTheme: GoogleFonts.beVietnamProTextTheme(Theme.of(context).textTheme),
      ),
      home: StreamBuilder<User?>(
        stream: AuthController().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
