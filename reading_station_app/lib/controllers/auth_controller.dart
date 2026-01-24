import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
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
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper to handle Firebase Auth messages in Vietnamese
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng bởi tài khoản khác.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      case 'operation-not-allowed':
        return 'Đăng nhập bằng Email/Mật khẩu chưa được bật.';
      default:
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }
}
