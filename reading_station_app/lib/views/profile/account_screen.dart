import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
               child: Stack(
                 alignment: Alignment.bottomRight,
                 children: [
                   const CircleAvatar(
                     radius: 50,
                     backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=profile'),
                   ),
                   Container(
                     padding: const EdgeInsets.all(6),
                     decoration: const BoxDecoration(
                       color: Color(0xFFFF5722),
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                   )
                 ],
               ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Thay đổi ảnh đại diện',
              style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold, fontSize: 13),
            ),

            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Thông tin cá nhân', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ),
            const SizedBox(height: 10),

            _buildInfoCard(
              children: [
                _buildInfoRow('Họ tên', 'Anh lính cứu hỏa'),
                _buildDivider(),
                _buildInfoRow('Giới thiệu', 'Chưa cập nhật', isDataMissing: true),
                _buildDivider(),
                _buildInfoRow('Email', 'linhcuuhoa@gmail.com', isLocked: true),
                _buildDivider(),
                _buildInfoRow('Số điện thoại', '0985321254'),
              ],
            ),

            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Bảo mật', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ),
            const SizedBox(height: 10),
            
             _buildInfoCard(
              children: [
                ListTile(
                  title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () {},
                )
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 20),

             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(15),
               decoration: BoxDecoration(
                 color: const Color(0xFFFFEBEE),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Column(
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: const [
                       Text('Xóa Tài Khoản', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                       Icon(Icons.delete_outline, color: Colors.red),
                     ],
                   ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hành động này không thể hoàn tác. Dữ liệu của bạn sẽ bị xóa vĩnh viễn',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLocked = false, bool isDataMissing = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isDataMissing ? Colors.grey : Colors.black54,
                  fontSize: 14,
                ),
              ),
              if (isLocked) ...[
                const SizedBox(width: 8),
                const Icon(Icons.lock_outline, size: 14, color: Colors.redAccent),
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.white);
  }
}
