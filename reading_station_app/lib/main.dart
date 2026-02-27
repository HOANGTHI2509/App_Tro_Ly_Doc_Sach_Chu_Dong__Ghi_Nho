import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reading_station_app/firebase_options.dart';
import 'package:reading_station_app/controllers/auth_controller.dart';
import 'package:reading_station_app/views/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reading_station_app/views/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book App UI',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: false, 
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

