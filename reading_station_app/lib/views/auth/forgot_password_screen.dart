import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/auth_controller.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final _authController = AuthController();

  Future<void> _handleReset() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email của bạn')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authController.sendPasswordResetEmail(_emailController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã xác minh đã được gửi đến email của bạn')),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              email: _emailController.text.trim(),
              type: OtpType.recovery,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF4A745B);
    const Color bgBeige = Color(0xFFF9F7F2);
    const Color inputBg = Color(0xFFEFECE5);

    return Scaffold(
      backgroundColor: bgBeige,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E35)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quên mật khẩu',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2C3E35), fontFamily: 'Serif'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Nhập email của bạn để nhận mã xác minh đặt lại mật khẩu.',
                style: TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),
              const SizedBox(height: 40),
              const Text(
                'EMAIL',
                style: TextStyle(color: Color(0xFF757575), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.black54),
                    hintText: 'name@gmail.com',
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Gửi mã xác minh',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
