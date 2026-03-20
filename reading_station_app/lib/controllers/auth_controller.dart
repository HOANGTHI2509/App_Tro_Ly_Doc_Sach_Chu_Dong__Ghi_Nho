import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.onAuthStateChange.map((event) => event.session?.user);

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.';
    }
  }

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final res = await _auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      // Insert user profile into public.users table
      if (res.user != null) {
        try {
          await Supabase.instance.client.from('users').insert({
            'id': res.user!.id,
            'email': email,
            'name': name,
          });
        } catch (e) {
          // Ignore error if row already exists or RLS blocks it initially
          print('Lỗi tạo user info profile: $e');
        }
      }
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.';
    }
  }

  // Verify OTP for signup or recovery
  Future<void> verifyOTP({
    required String email, 
    required String token, 
    OtpType type = OtpType.signup,
  }) async {
    try {
      await _auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Mã xác minh không hợp lệ hoặc đã hết hạn.';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi khi gửi yêu cầu. Vui lòng thử lại.';
    }
  }

  // Update password (after OTP verification, the user has a temporary session)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi khi cập nhật mật khẩu.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper to handle Supabase Auth messages in Vietnamese
  String _handleAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Email hoặc mật khẩu không chính xác.';
    } else if (msg.contains('already registered')) {
      return 'Email này đã được sử dụng bởi tài khoản khác.';
    } else if (msg.contains('password')) {
      return 'Mật khẩu không đáp ứng yêu cầu an toàn.';
    }
    return 'Đã xảy ra lỗi: ${e.message}';
  }
}
