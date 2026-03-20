import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../controllers/auth_controller.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

// Stream cung cấp trạng thái đăng nhập từ Supabase Auth
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authControllerProvider).authStateChanges;
});

// FutureProvider lấy chi tiết thông tin user từ bảng 'users' (chứa 'role')
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authUser = ref.watch(authStateProvider).value;
  
  if (authUser == null) return null;

  try {
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', authUser.id)
        .single();
        
    return UserModel.fromJson(response);
  } catch (e) {
    print('Error fetching user data: \$e');
    return null;
  }
});
