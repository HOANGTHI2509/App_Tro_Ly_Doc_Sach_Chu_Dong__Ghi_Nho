import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showError('Vui lòng điền đầy đủ các trường.');
      return;
    }

    if (newPass != confirmPass) {
      _showError('Mật khẩu xác nhận không khớp.');
      return;
    }

    if (newPass.length < 8) {
      _showError('Mật khẩu mới phải có ít nhất 8 ký tự.');
      return;
    }

    FocusScope.of(context).unfocus(); // Đóng bàn phím

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null || user.email == null) {
        throw 'Không tìm thấy phiên đăng nhập. Vui lòng đăng nhập lại.';
      }

      // Xác minh mật khẩu cũ bằng cách đăng nhập lại nháp
      // Note: Nếu mật khẩu sai nó sẽ văng Exception (có catch dưới)
      await Supabase.instance.client.auth.signInWithPassword(
        email: user.email!,
        password: oldPass,
      );

      // Nếu pass, tiến hành cập nhật mật khẩu mới
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPass),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công!'),
          backgroundColor: Color(0xFF4A745B),
        ),
      );
      Navigator.pop(context);

    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.toLowerCase().contains('invalid login credentials')) {
        msg = 'Mật khẩu cũ không chính xác.';
      }
      _showError(msg);
    } catch (e) {
      _showError('Có lỗi xảy ra: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(
            color: Color(0xFF385A46),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF4A745B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFDFE6D9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset_rounded, size: 48, color: Color(0xFF4A745B)),
            ),
            const SizedBox(height: 24),
            Text(
              'Vui lòng nhập mật khẩu hiện tại và mật khẩu\nmới để bảo mật tài khoản của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildPasswordField(
              label: 'Mật khẩu hiện tại',
              hint: 'Nhập mật khẩu cũ',
              controller: _oldPasswordController,
              isObscure: _obscureOld,
              onToggleVisibility: () => setState(() => _obscureOld = !_obscureOld),
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'Mật khẩu mới',
              hint: 'Ít nhất 8 ký tự',
              controller: _newPasswordController,
              isObscure: _obscureNew,
              onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'Xác nhận mật khẩu mới',
              hint: 'Nhập lại mật khẩu mới',
              controller: _confirmPasswordController,
              isObscure: _obscureConfirm,
              onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EAE0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFF7A6242), shape: BoxShape.circle),
                    child: const Icon(Icons.info_outline, color: Colors.white, size: 12),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Một mật khẩu mạnh cần có ít nhất ',
                        style: TextStyle(color: Color(0xFF7A6242), fontSize: 13, height: 1.5),
                        children: [
                          TextSpan(text: '8 ký tự', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ', bao gồm cả '),
                          TextSpan(text: 'chữ cái', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' và '),
                          TextSpan(text: 'chữ số', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' để đảm bảo an toàn cho tài khoản Trạm Đọc của bạn.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A745B),
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Cập nhật mật khẩu', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B263B)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(fontSize: 14, letterSpacing: 1.2),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14, letterSpacing: 0),
            filled: true,
            fillColor: const Color(0xFFEFECE5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: const Color(0xFF757575),
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}
