import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../main_screen.dart';
import '../admin/admin_main_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        final userModelAsync = ref.watch(currentUserProvider);
        return userModelAsync.when(
          data: (userModel) {
            if (userModel == null) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFFFA6400)),
                ),
              );
            }
            if (userModel.isAdmin) {
              return const AdminMainScreen();
            }
            return const MainScreen();
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFA6400)),
            ),
          ),
          error: (error, stackTrace) => Scaffold(
            body: Center(
              child: Text('Lỗi: $error'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFA6400)),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Lỗi đăng nhập: $error'),
        ),
      ),
    );
  }
}
