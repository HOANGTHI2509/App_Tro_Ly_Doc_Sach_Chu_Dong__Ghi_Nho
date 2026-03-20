import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../../providers/nav_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/review_settings_provider.dart';
import '../../providers/community_provider.dart';
import '../auth/login_screen.dart';
import 'account_screen.dart';
import 'notification_settings_screen.dart';
import 'help_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cá nhân', style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
            // Settings icon could go here
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Info
            Center(
              child: Column(
                children: [
                   Stack(
                     alignment: Alignment.bottomRight,
                     children: [
                       const CircleAvatar(
                         radius: 50,
                         backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=profile'),
                       ),
                       Container(
                         padding: const EdgeInsets.all(4),
                         decoration: const BoxDecoration(
                           color: Color(0xFFFF5722),
                           shape: BoxShape.circle,
                         ),
                         child: const Icon(Icons.star, color: Colors.white, size: 16),
                       )
                     ],
                   ),
                   const SizedBox(height: 15),
                   const Text(
                     'Anh lính cứu hỏa',
                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 5),
                   Text(
                     'linhcuuhoa@gmail.com',
                     style: TextStyle(color: Colors.grey[600], fontSize: 13),
                   ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('45', 'Sách', const Color(0xFFFF5722)),
                _buildStatItem('32', 'Ghi chú', const Color(0xFFFF5722)),
                _buildStatItem('186', 'Chuỗi ngày', const Color(0xFFFF5722)),
              ],
            ),
            
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // Menu Options
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'Tài khoản',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountScreen()));
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications_none,
              title: 'Thông báo & Nhắc nhở',
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()));
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.sync,
              title: 'Đồng bộ & Thiết bị',
              onTap: () {},
              trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ),
            
            const SizedBox(height: 20),
            Container(height: 8, color: Colors.grey[100]),
            const SizedBox(height: 20),

             _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Trợ giúp & Phản hồi',
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
              },
            ),
             _buildMenuItem(
              context,
              icon: Icons.verified_user_outlined,
              title: 'Điều khoản & quyền riêng tư',
              onTap: () {},
            ),

            const SizedBox(height: 40),

            // Logout
            TextButton(
              onPressed: () async {
                 await AuthController().signOut();
                 // Invalidate all global providers to clear cache for the next user
                 ref.invalidate(navProvider);
                 ref.invalidate(userBooksProvider);
                 ref.invalidate(allNotesProvider);
                 ref.invalidate(dueNotesProvider);
                 ref.invalidate(totalNotesCountProvider);
                 ref.invalidate(memorizedNotesCountProvider);
                 ref.invalidate(streakProvider);
                 ref.invalidate(weeklyStudyDaysProvider);
                 ref.invalidate(reviewSettingsProvider);
                 ref.invalidate(feedProvider);
                 ref.invalidate(friendsProvider);
                 ref.invalidate(pendingRequestsProvider);
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Color(0xFFFF5722),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
