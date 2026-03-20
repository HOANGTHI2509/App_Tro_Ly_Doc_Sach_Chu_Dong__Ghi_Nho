import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../../providers/nav_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/review_settings_provider.dart';
import '../../providers/community_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'account_screen.dart';
import 'notification_settings_screen.dart';
import 'help_screen.dart';
import 'change_password_screen.dart';
import '../../providers/theme_provider.dart';

final userProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return {};
  final data = await Supabase.instance.client.from('users').select().eq('id', user.id).maybeSingle();
  return data ?? {};
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _green = Color(0xFF38684A);
  static const _bgBeige = Color(0xFFF8F6F0);
  static const _borderColor = Color(0xFFEAE5DC);
  static const _sectionTitleColor = Color(0xFF7A6242);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Chưa có email';

    final profileAsync = ref.watch(userProfileProvider);
    final name = profileAsync.when(
      data: (data) => data['name'] ?? 'Người dùng',
      loading: () => 'Đang tải...',
      error: (_, __) => 'Chưa cập nhật',
    );
    final String? avatarUrl = profileAsync.value?['avatar_url'];

    final booksAsync = ref.watch(userBooksProvider);
    final notesAsync = ref.watch(allNotesProvider);
    final streakAsync = ref.watch(streakProvider);

    final booksCount = booksAsync.when(data: (books) => books.length.toString(), loading: () => '-', error: (_, __) => '-');
    final notesCount = notesAsync.when(data: (notes) => notes.length.toString(), loading: () => '-', error: (_, __) => '-');
    final streakCount = streakAsync.when(data: (streak) => streak.toString(), loading: () => '-', error: (_, __) => '-');

    return Scaffold(
      backgroundColor: _bgBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                child: const Text(
                  'Cá nhân',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                    color: _green,
                  ),
                ),
              ),

              // Avatar & Name
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _green.withOpacity(0.2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: _green,
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'A',
                            style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B263B)),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildStatItem(booksCount, 'Sách', Icons.menu_book_rounded),
                    const SizedBox(width: 12),
                    _buildStatItem(notesCount, 'Ghi chú', Icons.sticky_note_2_rounded),
                    const SizedBox(width: 12),
                    _buildStatItem(streakCount, 'Chuỗi ngày', Icons.local_fire_department_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tài khoản
                    _buildSectionTitle('Tài khoản'),
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Thông tin cá nhân',
                        subtitle: 'Quản lý tên, email và ảnh đại diện',
                        showBorder: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen())),
                      ),
                      _buildMenuItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Đổi mật khẩu',
                        subtitle: 'Cập nhật bảo mật cho tài khoản',
                        showBorder: false,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                      ),
                    ]),
                    // Thông báo
                    _buildSectionTitle('Thông báo'),
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Thông báo',
                        subtitle: 'Tùy chỉnh nhận thông báo',
                        showBorder: false,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Khác
                    _buildSectionTitle('Khác'),
                    _buildMenuCard([
                      _buildMenuItem(
                        icon: Icons.cloud_sync_outlined,
                        title: 'Đồng bộ dữ liệu',
                        showBorder: true,
                        onTap: () async {
                          // Hiện thanh trạng thái Đang tải
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  SizedBox(
                                    width: 16, height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Đang đồng bộ dữ liệu với máy chủ...', style: TextStyle(fontFamily: 'Serif')),
                                ],
                              ),
                              backgroundColor: Color(0xFF4A745B),
                              duration: Duration(seconds: 1),
                            ),
                          );

                          // Quét sạch bộ nhớ tạm (Cache) để App tự kéo dữ liệu mới từ CSDL (Supabase)
                          ref.invalidate(userProfileProvider);
                          ref.invalidate(userBooksProvider);
                          ref.invalidate(allNotesProvider);
                          ref.invalidate(dueNotesProvider);
                          ref.invalidate(totalNotesCountProvider);
                          ref.invalidate(memorizedNotesCountProvider);
                          ref.invalidate(streakProvider);
                          ref.invalidate(weeklyStudyDaysProvider);
                          ref.invalidate(feedProvider);
                          ref.invalidate(friendsProvider);
                          ref.invalidate(pendingRequestsProvider);

                          // Chờ trễ giả lập Network
                          await Future.delayed(const Duration(seconds: 1));
                          
                          if (!context.mounted) return;
                          
                          // Thông báo thành công
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đồng bộ dữ liệu thành công! ✨', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Serif')),
                              backgroundColor: Color(0xFF4A745B),
                              duration: Duration(seconds: 2), // Hiện 2 giây
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Hỗ trợ & Phản hồi',
                        showBorder: false,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen())),
                      ),
                    ]),
                    const SizedBox(height: 32),

                    // Logout Button
                    Consumer(
                      builder: (ctx, ref, _) => SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await AuthController().signOut();
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
                          icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFD32F2F)),
                          label: const Text(
                            'Đăng xuất',
                            style: TextStyle(
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.5),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'TRẠM ĐỌC V1.0.0 • MADE WITH HEART',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // padding for bottom nav
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Serif',
          color: _sectionTitleColor,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: _borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool showBorder = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: showBorder
            ? const BoxDecoration(
                border: Border(bottom: BorderSide(color: _borderColor, width: 1.5)),
              )
            : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFE4E9E2), // Greenish background for icon
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _green, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B263B),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (trailing != null)
              trailing
            else
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: _borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: _green, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B263B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
