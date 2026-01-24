import 'package:flutter/material.dart';

class AddFriendScreen extends StatelessWidget {
  const AddFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm vào Vòng tròn',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFFFEBE5).withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            _buildSectionHeader('Gợi ý cho bạn'),
            const SizedBox(height: 15),
            _buildFriendItem('Minh Anh', '3 bạn chung . Đọc kinh doanh', 'https://i.pravatar.cc/150?u=minhanh', AddStatus.connect),
            _buildFriendItem('Hoàng Tuấn', 'Thường đọc sách Self_help', 'https://i.pravatar.cc/150?u=hoangtuan', AddStatus.connect),
            _buildFriendItem('Linh Đan', 'Đã gửi lời mời', 'https://i.pravatar.cc/150?u=linhdan', AddStatus.pending),

            const SizedBox(height: 30),

            _buildSectionHeader('Từ danh bạ của bạn'),
            const SizedBox(height: 15),
            _buildFriendItem('Trần đức', 'duc.tran@example.com', 'https://i.pravatar.cc/150?u=tranduc', AddStatus.connect),
            _buildFriendItem('Phạm Hương', 'huong.pham@example.com', 'https://i.pravatar.cc/150?u=phamhuong', AddStatus.connect),

            const SizedBox(height: 30),
            
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share, color: Color(0xFFFF5722), size: 18),
                label: const Text('Mời bạn bè qua link', style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildFriendItem(String name, String info, String avatarUrl, AddStatus status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(info, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          if (status == AddStatus.connect)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                minimumSize: const Size(80, 32),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: const Text('Kết bạn', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          else
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               decoration: BoxDecoration(
                 color: Colors.grey[200],
                 borderRadius: BorderRadius.circular(20),
               ),
               child: const Text('Đã gửi', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
             )
        ],
      ),
    );
  }
}

enum AddStatus { connect, pending }
