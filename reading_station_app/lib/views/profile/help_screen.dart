import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
       appBar: AppBar(
        title: const Text('Trợ giúp & Nhắc nhở', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('CÂU HỎI THƯỜNG GẶP'),
            const SizedBox(height: 10),
            _buildCard([
              _buildRow('Làm sao để tạo flashcard?', onTap: () {}),
              const Divider(height: 1),
              _buildRow('Cách đồng bộ dữ liệu?', onTap: () {}),
              const Divider(height: 1),
              _buildRow('Khôi phục mật khẩu', onTap: () {}),
            ]),

            const SizedBox(height: 25),

            _buildSectionHeader('LIÊN HỆ HỖ TRỢ'),
            const SizedBox(height: 10),
            _buildCard([
               _buildRow(
                 'Gửi email hỗ trợ', 
                 subtitle: 'hotro@tramdoc.com', 
                 icon: Icons.mail_outline_outlined, 
                 iconColor: Colors.red,
                 onTap: () {
                    // Open mail app
                 }
               ),
               const Divider(height: 1),
               _buildRow(
                 'Chat với đội ngũ', 
                 subtitle: 'Phản hồi trong 24h', 
                 icon: Icons.chat_bubble_outline, 
                 iconColor: Colors.orange,
                 onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportRequestScreen()));
                 }
               ),
            ]),

            const SizedBox(height: 25),

             _buildSectionHeader('GÓP Ý & BÁO LỖI'),
            const SizedBox(height: 10),
            _buildCard([
              _buildRow('Báo cáo sự cố', icon: Icons.warning_amber_rounded, iconColor: Colors.redAccent, onTap: () {}),
               const Divider(height: 1),
              _buildRow('Góp ý tính năng mới', icon: Icons.lightbulb_outline, iconColor: Colors.orange, onTap: () {}),
            ]),

             const SizedBox(height: 25),

             _buildSectionHeader('THÔNG TIN & PHÁP LÝ'),
            const SizedBox(height: 10),
             _buildCard([
              _buildRow('Điều khoản & Chính sách', onTap: () {}),
             ]),

          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow(String title, {String? subtitle, IconData? icon, Color? iconColor, required VoidCallback onTap}) {
    return ListTile(
      leading: icon != null 
        ? Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor!.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20),
          )
        : null,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class SupportRequestScreen extends StatelessWidget {
  const SupportRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Gửi hỗ trợ', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chủ đề cần hỗ trợ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: 'Chọn vấn đề của bạn',
                  items: ['Chọn vấn đề của bạn', 'Lỗi ứng dụng', 'Tài khoản', 'Khác'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
            ),

            const SizedBox(height: 20),

             const Text('Email của bạn', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'abc@gmail.com',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 5),
            Text('Chúng tôi sẽ gửi phản hồi qua email này', style: TextStyle(color: Colors.grey[500], fontSize: 11)),

            const SizedBox(height: 20),

             const Text('Nội Dung chi tiết', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
             TextField(
               maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Mô tả nội dung lỗi bạn gặp phải...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 10),
            Row(
              children: const [
                 Icon(Icons.attach_file, color: Color(0xFFFF5722), size: 18),
                 SizedBox(width: 5),
                 Text('Tải hình ảnh chi tiết lỗi nếu có', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),

            const SizedBox(height: 40),

             SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: const Text('Gửi hỗ trợ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
