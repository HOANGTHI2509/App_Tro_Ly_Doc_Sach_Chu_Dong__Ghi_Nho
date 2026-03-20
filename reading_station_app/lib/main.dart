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
import 'package:reading_station_app/providers/theme_provider.dart';
import 'package:reading_station_app/views/admin/admin_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase correctly for Auth and Database
  await Supabase.initialize(
    url: 'https://kvechqvsflmmxruikrtt.supabase.co',
    anonKey: 'sb_publishable_Bn9x0JxeSONUEDX_ItvyJQ__9hwuUMT',
  );

  // Initialize Notification Service
  await NotificationService().init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Trạm Đọc',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: GoogleFonts.beVietnamPro().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFA6400), primary: const Color(0xFFFA6400)),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: Colors.black)),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: GoogleFonts.beVietnamPro().fontFamily),
        primaryTextTheme: ThemeData.dark().textTheme.apply(fontFamily: GoogleFonts.beVietnamPro().fontFamily),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFA6400), primary: const Color(0xFFFA6400), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: Colors.white)),
      ),
      home: StreamBuilder<User?>(
        stream: AuthController().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return AuthWrapper(user: snapshot.data!);
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final User user;
  const AuthWrapper({super.key, required this.user});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<Map<String, dynamic>?> _roleFuture;

  @override
  void initState() {
    super.initState();
    _roleFuture = Supabase.instance.client
        .from('users')
        .select('role')
        .eq('id', widget.user.id)
        .maybeSingle();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _roleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFA6400))));
        }
        if (snapshot.hasData && snapshot.data!['role'] == 'admin') {
          return const AdminMainScreen();
        }
        return const MainScreen();
      },
    );
  }
}
