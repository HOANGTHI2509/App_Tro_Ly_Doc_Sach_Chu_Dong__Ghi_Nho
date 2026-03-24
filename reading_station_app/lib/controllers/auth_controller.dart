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
      // Giới hạn 1 thiết bị/thời điểm: Đăng xuất toàn bộ các phiên đăng nhập ở thiết bị khác
      try {
        await _auth.signOut(scope: SignOutScope.others);
      } catch (_) {}
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

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi khi gửi email xác minh.';
    }
  }

  // Verify OTP
  Future<void> verifyOTP({required String email, required String token, required OtpType type}) async {
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

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Không thể cập nhật mật khẩu lúc này.';
    }
  }

  // Helper to handle Supabase Auth messages in Vietnamese
  String _handleAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid email') || msg.contains('wrong password') || msg.contains('credentials')) {
      return 'Email hoặc mật khẩu không chính xác. Hoặc tài khoản chưa tồn tại.';
    } else if (msg.contains('already registered')) {
      return 'Email này đã được sử dụng bởi tài khoản khác.';
    } else if (msg.contains('password')) {
      return 'Mật khẩu quá ngắn hoặc không đáp ứng yêu cầu an toàn.';
    }
    return 'Đã xảy ra lỗi: ${e.message}';
  }
}
