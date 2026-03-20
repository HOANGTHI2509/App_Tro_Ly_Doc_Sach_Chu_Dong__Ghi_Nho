import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'support_chat_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF38684A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trạm Đọc',
          style: TextStyle(
            color: Color(0xFF38684A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trợ giúp & Phản hồi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Color(0xFF1B263B),
              ),
            ),
            const SizedBox(height: 20),
            
            // Câu hỏi thường gặp
            _buildSectionHeader('Câu hỏi thường gặp'),
            _buildFAQCard(icon: Icons.style_rounded, title: 'Làm sao để tạo flashcard?', onTap: (){}),
            _buildFAQCard(icon: Icons.sync_rounded, title: 'Cách đồng bộ dữ liệu?', onTap: (){}),
            _buildFAQCard(icon: Icons.local_library_rounded, title: 'Quản lý thư viện số', onTap: (){}),
            _buildFAQCard(icon: Icons.account_balance_wallet_rounded, title: 'Vấn đề thanh toán', isBeige: true, onTap: (){}),

            // Liên hệ hỗ trợ
            _buildSectionHeader('Liên hệ hỗ trợ'),
            _buildContactButton(
              title: 'Gửi email cho chúng tôi',
              icon: Icons.email_rounded,
              bgColor: const Color(0xFF4A745B),
              fgColor: Colors.white,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportRequestScreen()));
              },
            ),
            _buildContactButton(
              title: 'Chat với đội ngũ hỗ trợ',
              icon: Icons.chat_bubble_rounded,
              bgColor: const Color(0xFFE8E5DC),
              fgColor: const Color(0xFF4A745B),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportChatScreen()));
              }
            ),

            // (Góp ý cho Trạm Đọc section removed as requested)

            const SizedBox(height: 48),

            // Footer Quote
            const Center(
              child: Text(
                '"Tri thức là chìa khóa, sự hỗ trợ là hành trang."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Serif',
                  color: Color(0xFFBDBDBD),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String left, {String? right}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
              color: Color(0xFF38684A),
            ),
          ),
          if (right != null)
            Text(
              right,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7A6242), // Brownish olive
                fontFamily: 'Serif',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAQCard({required IconData icon, required String title, bool isBeige = false, VoidCallback? onTap}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isBeige ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: isBeige ? const Color(0xFFEBE5DB) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isBeige ? const Color(0xFFDCD6CA) : const Color(0xFFEAF0EA),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF38684A), size: 18),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B263B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color fgColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: fgColor, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: fgColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackButton({
    required String title,
    required IconData icon,
    required Color bgColor,
    required Color primaryColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SupportRequestScreen extends StatefulWidget {
  const SupportRequestScreen({super.key});

  @override
  State<SupportRequestScreen> createState() => _SupportRequestScreenState();
}

class _SupportRequestScreenState extends State<SupportRequestScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedSubject = 'Chọn chủ đề hỗ trợ';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      // Có thể lấy tên từ meta data nếu có
      final metadata = user.userMetadata;
      if (metadata != null && metadata.containsKey('name')) {
         _nameController.text = metadata['name'];
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty || _selectedSubject == 'Chọn chủ đề hỗ trợ') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      await Supabase.instance.client.from('support_requests').insert({
        if (user != null) 'user_id': user.id,
        'name': name,
        'email': email,
        'subject': _selectedSubject,
        'message': message,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi yêu cầu thành công! Chúng tôi sẽ phản hồi sớm nhất.'),
          backgroundColor: Color(0xFF4A745B),
        ),
      );
      Navigator.pop(context); // Quay lại sau khi gửi thành công
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi yêu cầu: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        title: const Text('Gửi email hỗ trợ', style: TextStyle(color: Color(0xFF385A46), fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF4A745B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liên hệ với Trạm Đọc',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Color(0xFF1B263B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn có thắc mắc hay góp ý? Hãy để lại lời nhắn,\nđội ngũ hỗ trợ sẽ phản hồi bạn sớm nhất có thể.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3ED),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEBE6DF), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Họ và tên'),
                  _buildTextField('Nhập họ và tên', _nameController),
                  const SizedBox(height: 20),
                  _buildLabel('Địa chỉ email'),
                  _buildTextField('Ví dụ: email@domain.com', _emailController),
                  const SizedBox(height: 20),
                  _buildLabel('Tiêu đề'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F5),
                      border: Border.all(color: const Color(0xFFEBE6DF), width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedSubject,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                        items: ['Chọn chủ đề hỗ trợ', 'Báo cáo sự cố', 'Góp ý tính năng', 'Tài khoản', 'Khác'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 14, color: value == 'Chọn chủ đề hỗ trợ' ? const Color(0xFF424242) : const Color(0xFF1B263B))),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedSubject = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Nội dung tin nhắn'),
                  _buildTextField('Bạn cần chúng tôi giúp gì?', _messageController, maxLines: 5),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitRequest,
                      icon: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      label: Text(_isLoading ? 'Đang gửi...' : 'Gửi', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A745B),
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(Icons.access_time_filled, 'Thời gian phản hồi', 'Thường trong vòng 24 giờ làm việc.'),
            const SizedBox(height: 16),
            _buildInfoCard(Icons.email_rounded, 'Email trực tiếp', 'hotro@tramdoc.vn'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4A3C2A))),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFAF8F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEBE6DF), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEBE6DF), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(16),
           borderSide: const BorderSide(color: Color(0xFF4A745B), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE9), // Soft beige
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF7A6242),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B263B))),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

