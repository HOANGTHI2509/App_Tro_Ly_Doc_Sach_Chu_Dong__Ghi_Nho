import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isTermsAccepted = false;
  bool _isLoading = false;
  final _authController = AuthController();

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
      return;
    }

    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với điều khoản sử dụng')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authController.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );
      
      if (mounted) {
        // Pop all routes and go to main wrapper (which shows home because we are logged in)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đăng ký',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tạo tài khoản để bắt đầu xây dựng thư viện tri thức riêng của bạn.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              _buildLabel('Họ và tên'),
              _buildTextField(_nameController, 'Nhập họ tên của bạn'),
              
              const SizedBox(height: 20),
              
              _buildLabel('Email'),
              _buildTextField(_emailController, 'name@gmail.com'),
              
              const SizedBox(height: 20),
              
              _buildLabel('Mật khẩu'),
              _buildTextField(_passwordController, '........', obscureText: true),
              
              const SizedBox(height: 20),
              
              _buildLabel('Xác nhận mật khẩu'),
              _buildTextField(_confirmPasswordController, 'Nhập lại mật khẩu', obscureText: true),
              
              const SizedBox(height: 20),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _isTermsAccepted,
                      activeColor: const Color(0xFFFF5722),
                      onChanged: (val) {
                        setState(() => _isTermsAccepted = val ?? false);
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 13),
                        children: [
                          TextSpan(text: 'Tôi đồng ý với '),
                          TextSpan(
                            text: 'Điều khoản sử dụng',
                            style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' và '),
                          TextSpan(
                            text: 'Chính sách bảo mật',
                            style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' của Trạm Đọc'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      'Tạo tài khoản',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text on orange button
                      ),
                    ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Center(child: Text('Hoặc đăng ký với', style: TextStyle(color: Colors.grey, fontSize: 12))),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                   Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.facebook, color: Colors.blue),
                      label: const Text('Facebook', style: TextStyle(color: Colors.black)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.pink),
                      label: const Text('Instagram', style: TextStyle(color: Colors.black)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              
              Center(
                child: GestureDetector(
                  onTap: () {
                     // Normally you might modify the navigation stack, but here we can just pop if we came from login
                     Navigator.pop(context); 
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      children: [
                        TextSpan(text: 'Đã có tài khoản? '),
                        TextSpan(
                          text: 'Đăng nhập',
                          style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
