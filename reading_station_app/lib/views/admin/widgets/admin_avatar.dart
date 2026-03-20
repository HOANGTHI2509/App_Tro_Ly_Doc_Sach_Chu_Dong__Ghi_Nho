import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/login_screen.dart';

/// Widget avatar admin — nhấn vào để xem hồ sơ & đăng xuất
class AdminAvatar extends StatelessWidget {
  const AdminAvatar({super.key});

  void _showProfileSheet(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final meta = user?.userMetadata ?? {};
    final avatarUrl = meta['avatar_url'] as String?;
    final fullName = (meta['full_name'] ?? meta['name'] ?? 'Admin') as String;
    final email = user?.email ?? '';
    final createdAt = user?.createdAt ?? '';

    String joinDate = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt).toLocal();
        joinDate = '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Avatar lớn
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFF0C4A6E),
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Tên
            Text(
              fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0C4A6E),
              ),
            ),
            const SizedBox(height: 6),

            // Badge admin
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 14, color: Color(0xFF7C3AED)),
                  SizedBox(width: 4),
                  Text(
                    'Quản trị viên',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Thông tin chi tiết
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.email_outlined, 'Email', email),
                  if (joinDate.isNotEmpty) ...[
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _infoRow(Icons.calendar_today_outlined, 'Ngày tham gia', joinDate),
                  ],
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _infoRow(Icons.verified_user_outlined, 'Quyền hạn', 'Toàn quyền quản trị'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút đăng xuất
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await supabase.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata;
    final avatarUrl = meta?['avatar_url'] as String?;
    final fullName = (meta?['full_name'] ?? meta?['name'] ?? 'Admin') as String;

    return GestureDetector(
      onTap: () => _showProfileSheet(context),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFF0C4A6E),
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              )
            : null,
      ),
    );
  }
}

Widget _infoRow(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, size: 18, color: const Color(0xFF64748B)),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        ],
      ),
    ],
  );
}
