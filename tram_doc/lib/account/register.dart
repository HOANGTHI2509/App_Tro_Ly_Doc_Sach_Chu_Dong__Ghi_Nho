import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Đăng ký",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Tạo tài khoản để bắt đầu xây dựng thư viện tri thức riêng của bạn.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Các ô nhập liệu
            _buildFieldLabel("Họ và tên"),
            _buildTextField("Nhập họ tên của bạn"),

            _buildFieldLabel("Email"),
            _buildTextField("name@gmail.com"),

            _buildFieldLabel("Mật khẩu"),
            _buildTextField("........", isPassword: true),

            _buildFieldLabel("Xác nhận mật khẩu"),
            _buildTextField("Nhập lại mật khẩu", isPassword: true),

            const SizedBox(height: 10),

            // Checkbox Điều khoản
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  activeColor: const Color(0xFFFF5722),
                  onChanged: (value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                ),
                const Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: "Tôi đồng ý với ",
                      style: TextStyle(fontSize: 12),
                      children: [
                        TextSpan(
                          text: "Điều khoản sử dụng",
                          style: TextStyle(
                            color: Color(0xFFFF5722),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: " và "),
                        TextSpan(
                          text: "Chính sách bảo mật",
                          style: TextStyle(
                            color: Color(0xFFFF5722),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Nút Tạo tài khoản
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Tạo tài khoản",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Hoặc đăng kí với",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Social Buttons
            Row(
              children: [
                _buildSocialButton("Facebook", Icons.facebook, Colors.blue),
                const SizedBox(width: 15),
                _buildSocialButton("Instagram", Icons.camera_alt, Colors.pink),
              ],
            ),

            const SizedBox(height: 30),

            // Chuyển sang Đăng nhập
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Đã có tài khoản? "),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Đăng nhập",
                    style: TextStyle(
                      color: Color(0xFFFF5722),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, IconData icon, Color color) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: color),
        label: Text(text, style: const TextStyle(color: Colors.black)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
