import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();
  bool _isLoading = false;

  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authController.signIn(email: _emailController.text.trim(), password: _passwordController.text.trim());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Top Logo
              Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.menu_book, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text('TRẠM ĐỌC', style: TextStyle(color: primaryGreen, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
                  const SizedBox(height: 6),
                  const Text('TRỢ LÝ ĐỌC SÁCH CHỦ ĐỘNG', style: TextStyle(color: Color(0xFF757575), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Đăng nhập',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E35),
                ),
              ),
              const SizedBox(height: 32),

              // Email
              const Text('EMAIL', style: TextStyle(color: Color(0xFF757575), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.black54),
                    hintText: 'email@example.com',
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Password
              const Text('MẬT KHẨU', style: TextStyle(color: Color(0xFF757575), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    hintText: '••••••••',
                    hintStyle: const TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Quên mật khẩu?', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),

              const SizedBox(height: 24),
              // Đăng nhập Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Đăng nhập', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
              ),

              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('HOẶC ĐĂNG NHẬP VỚI', style: TextStyle(color: Color(0xFF757575), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                ],
              ),

              const SizedBox(height: 32),
              // Social Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Image.network('https://img.icons8.com/color/48/000000/google-logo.png', width: 20, height: 20),
                      label: const Text('Google', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.facebook, color: Colors.blue, size: 24),
                      label: const Text('Facebook', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản? ', style: TextStyle(color: Color(0xFF757575))),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: const Text('Đăng ký ngay', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
