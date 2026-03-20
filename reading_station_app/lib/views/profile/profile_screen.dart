import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Theme Colors based on screenshot
  static const Color bgColor = Color(0xFFF9F8F4);
  static const Color primaryGreen = Color(0xFF5E715B);
  static const Color softGreen = Color(0xFFE8F5E9);
  static const Color accentOrange = Color(0xFFFA6400);
  static const Color textMain = Color(0xFF2C3E35);
  static const Color textSub = Color(0xFF7A7A7A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book, color: primaryGreen, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Cá nhân',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(Icons.person_outline, color: Colors.orangeAccent, size: 24),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Profile Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 60,
                            backgroundColor: softGreen,
                            backgroundImage: NetworkImage('https://img.freepik.com/free-vector/hand-drawn-flat-design-stack-books-illustration_23-2149341898.jpg'), // Using available asset pattern
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Minh Tú',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textMain,
                        fontFamily: 'Serif',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Hành trình vạn dặm bắt đầu từ những trang sách đầu tiên. 🌿',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textSub, fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Small Stats Grid
              Row(
                children: [
                   Expanded(
                    child: _buildStatCard('32', 'Sách đã đọc', Icons.library_books_outlined),
                  ),
                  const SizedBox(width: 15),
                   Expanded(
                    child: _buildStatCard('156', 'Ghi chú', Icons.description_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Streak Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EFE4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.bolt, color: primaryGreen, size: 30),
                    const SizedBox(height: 8),
                    const Text(
                      '12 ngày',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    const Text(
                      'Chuỗi ngày',
                      style: TextStyle(color: textSub, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Achievement Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thành tích',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Xem tất cả', style: TextStyle(color: textSub, fontSize: 12)),
                        Icon(Icons.chevron_right, size: 16, color: textSub),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildAchievementBadge('Mọt sách', const Color(0xFFFDEBB7), Icons.menu_book),
                    _buildAchievementBadge('Người ghi chép', const Color(0xFFC0E8C4), Icons.edit_note),
                    _buildAchievementBadge('Kiên trì', const Color(0xFFEAEAEA), Icons.calendar_today),
                    _buildAchievementBadge('Thành tựu i', const Color(0xFFF5F5F5), Icons.lock_outline, isLocked: true),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Menu List
              _buildMenuSection([
                _buildMenuTile(Icons.notifications_outlined, 'Thông báo ôn tập', () {}),
                _buildMenuTile(Icons.sync, 'Đồng bộ dữ liệu', () {}),
                _buildMenuTile(Icons.settings_outlined, 'Cài đặt', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                }),
                _buildMenuTile(Icons.help_outline, 'Trung tâm trợ giúp', () {}),
                _buildMenuTile(Icons.logout, 'Đăng xuất', () async {
                  await AuthController().signOut();
                }, isLogout: true),
              ]),

              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Trạm Đọc — Phiên bản 2.4.0',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryGreen, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textMain),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String label, Color color, IconData icon, {bool isLocked = false}) {
     return Padding(
       padding: const EdgeInsets.only(right: 15),
       child: Column(
         children: [
           Container(
             width: 70,
             height: 70,
             decoration: BoxDecoration(
               color: color,
               shape: BoxShape.circle,
               border: isLocked ? Border.all(color: Colors.grey[300]!, width: 1, style: BorderStyle.solid) : null,
             ),
             child: Icon(icon, color: isLocked ? Colors.grey : textMain, size: 30),
           ),
           const SizedBox(height: 8),
           Text(
             label,
             style: TextStyle(
               color: isLocked ? Colors.grey : textMain,
               fontSize: 11,
               fontWeight: FontWeight.w500,
             ),
           ),
         ],
       ),
     );
  }

  Widget _buildMenuSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isLogout ? Colors.redAccent : primaryGreen, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.redAccent : textMain,
        ),
      ),
      trailing: isLogout ? null : const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

