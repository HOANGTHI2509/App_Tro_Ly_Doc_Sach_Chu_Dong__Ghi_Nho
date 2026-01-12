import 'package:flutter/material.dart';
import 'package:tram_doc/account/register.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginSelected = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hình ảnh Header
            SizedBox(
              height: size.height * 0.4,
              width: double.infinity,
              child: Image.asset(
                'assets/img/login.jpg',
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    "Đăng Nhập",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  // Ô nhập liệu
                  _buildInput("Email hoặc Số điện thoại"),
                  const SizedBox(height: 15),
                  _buildInput("Mật khẩu", isPass: true),
                  const SizedBox(height: 30),

                  // Nút Đăng nhập & Đăng ký
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton("Đăng Nhập", isLoginSelected, () {
                          setState(() => isLoginSelected = true);
                        }),
                        _buildTabButton("Đăng ký", !isLoginSelected, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Hoặc đăng nhập bằng",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Social Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.facebook,
                        size: 45,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 30),
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 40,
                        color: Colors.pink[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, {bool isPass = false}) {
    return TextField(
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      ),
    );
  }

  Widget _buildTabButton(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFF5722) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
