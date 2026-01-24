import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Mock State
  bool dailyReminder = true;
  bool smartReminder = true;
  bool friendActivity = true;
  bool interactions = false;
  bool friendRequests = true;
  bool appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thông báo & Nhắc nhở', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('ÔN TẬP KIẾN THỨC'),
          const SizedBox(height: 10),
          _buildToggleItem(
            'Nhắc nhở hàng ngày',
            'Nhận thông báo để ôn tập flashcard',
            dailyReminder,
            (val) => setState(() => dailyReminder = val),
          ),
          Container(
             margin: const EdgeInsets.only(bottom: 20, top: 10),
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
             decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8)),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: const [
                 Text('Thời gian nhắc', style: TextStyle(fontWeight: FontWeight.bold)),
                 Text('08:00', style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold)),
               ],
             ),
          ),
           _buildToggleItem(
            'Nhắc nhở thông minh',
            'Chỉ nhắc khi có thẻ đến hạn ôn tập',
            smartReminder,
            (val) => setState(() => smartReminder = val),
          ),
           const SizedBox(height: 30),

           _buildSectionHeader('CỘNG ĐỒNG'),
           const SizedBox(height: 10),
           _buildToggleItem(
            'Hoạt động bạn bè',
            'Khi bạn bè thêm sách hoặc viết ghi chú',
            friendActivity,
            (val) => setState(() => friendActivity = val),
          ),
           const Divider(),
            _buildToggleItem(
            'Tương tác',
            'Khi ai đó thích hoặc bình luận bài viết',
            interactions,
            (val) => setState(() => interactions = val),
          ),
           const Divider(),
            _buildToggleItem(
            'Lời mời kết bạn',
            '',
            friendRequests,
            (val) => setState(() => friendRequests = val),
          ),

           const SizedBox(height: 30),

           _buildSectionHeader('HỆ THỐNG'),
           const SizedBox(height: 10),
           _buildToggleItem(
            'Cập nhật ứng dụng',
            'Thông tin về tính năng mới',
            appUpdates,
            (val) => setState(() => appUpdates = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 13),
    );
  }

  Widget _buildToggleItem(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ]
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value, 
              onChanged: onChanged,
              activeColor: const Color(0xFFFF5722),
            ),
          )
        ],
      ),
    );
  }
}
