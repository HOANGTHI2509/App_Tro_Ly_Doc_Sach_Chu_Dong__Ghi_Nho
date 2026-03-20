import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/community_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  // Hoạt động Cộng đồng
  bool _friendActivity = true;
  bool _friendRequests = true;

  // Gợi ý & Khác
  bool _systemUpdates = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _friendActivity = prefs.getBool('notif_friend_activity') ?? true;
      _friendRequests = prefs.getBool('notif_friend_requests') ?? true;
      _systemUpdates = prefs.getBool('notif_system_updates') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF38684A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cài đặt Thông báo',
          style: TextStyle(
            color: Color(0xFF38684A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE4EADF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  'Tùy chỉnh trải nghiệm',
                  style: TextStyle(
                    color: Color(0xFF38684A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Điều chỉnh cách Trạm Đọc đồng hành cùng\nhành trình tri thức của bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF59635D),
                    fontSize: 13,
                    height: 1.5,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD3DDD0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF38684A), size: 40),
                ),
              ],
            ),
          ),

          // Section 1: Hoạt động Cộng đồng
          _buildSectionHeader(Icons.people_alt_rounded, 'Hoạt động Cộng đồng'),
          _buildSectionCard([
            _buildToggleRow(
              title: 'Hoạt động từ bạn bè',
              subtitle: 'Khi bạn bè bắt đầu một cuốn sách mới.',
              value: _friendActivity,
              onChanged: (val) {
                setState(() => _friendActivity = val);
                _saveSetting('notif_friend_activity', val);
                ref.invalidate(feedProvider);
              },
              showBorder: true,
            ),
            _buildToggleRow(
              title: 'Lời mời kết bạn',
              subtitle: 'Thông báo khi có người muốn kết nối.',
              value: _friendRequests,
              onChanged: (val) {
                setState(() => _friendRequests = val);
                _saveSetting('notif_friend_requests', val);
                ref.invalidate(pendingRequestsProvider);
              },
              showBorder: false,
            ),
          ]),

          const SizedBox(height: 32),

          // Section 2: Gợi ý & Khác
          _buildSectionHeader(Icons.menu_book_rounded, 'Gợi ý & Khác'),
          _buildSectionCard([
            _buildToggleRow(
              title: 'Cập nhật hệ thống',
              subtitle: 'Tính năng mới và thay đổi quan trọng.',
              value: _systemUpdates,
              onChanged: (val) {
                setState(() => _systemUpdates = val);
                _saveSetting('notif_system_updates', val);
              },
              showBorder: false,
            ),
          ]),

          // Footer Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            alignment: Alignment.center,
            child: const Text(
              'Cài đặt của bạn sẽ được tự động đồng bộ hóa trên tất cả\nthiết bị đã đăng nhập.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 11,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A3C2A), size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4A3C2A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFECE5), width: 1.5),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showBorder = true,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: showBorder
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEFECE5), width: 1.5)),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1B263B),
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                    fontFamily: 'Serif',
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF568164),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFD1D1D1),
            ),
          ),
        ],
      ),
    );
  }
}
