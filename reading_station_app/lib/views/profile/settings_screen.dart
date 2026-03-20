import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme Colors
  static const Color bgColor = Color(0xFFF9F8F4);
  static const Color primaryGreen = Color(0xFF5E715B);
  static const Color textMain = Color(0xFF2C3E35);
  static const Color textSub = Color(0xFF7A7A7A);
  
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: textMain),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Premium Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E715B), Color(0xFF4A5D48)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'TRẠM ĐỌC PLUS',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gói Premium',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Kích hoạt để mở khóa tất cả tính năng ôn tập.',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDEBB7),
                      foregroundColor: textMain,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Nâng\ncấp', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, height: 1.1)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionTitle('Tài khoản'),
            _buildSectionContainer([
              _buildSettingTile(
                icon: Icons.account_circle_outlined,
                title: 'Thông tin cá nhân',
                subtitle: 'Quản lý tên, email và ảnh đại diện',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 60),
              _buildSettingTile(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                subtitle: 'Cập nhật bảo mật cho tài khoản',
                onTap: () {},
              ),
            ]),


            const SizedBox(height: 30),
            _buildSectionTitle('Giao diện'),
            _buildSectionContainer([
              _buildSettingTile(
                icon: Icons.dark_mode_outlined,
                title: 'Chế độ tối',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (val) => setState(() => isDarkMode = val),
                  activeColor: primaryGreen,
                ),
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 30),
            _buildSectionTitle('Khác'),
            _buildSectionContainer([
               _buildSettingTile(icon: Icons.notifications_outlined, title: 'Thông báo', onTap: () {}),
               const Divider(height: 1, indent: 60),
               _buildSettingTile(icon: Icons.sync, title: 'Đồng bộ dữ liệu', onTap: () {}),
               const Divider(height: 1, indent: 60),
               _buildSettingTile(icon: Icons.help_outline, title: 'Hỗ trợ & Phản hồi', onTap: () {}),
            ]),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await AuthController().signOut();
                  // No need to pop as AuthController will handle logout
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                label: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFEBEE)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                'TRẠM ĐỌC V2.4.0 • MADE WITH HEART',
                style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B6B4A)),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F0),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primaryGreen, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textMain),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: textSub)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildFontSizeBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
