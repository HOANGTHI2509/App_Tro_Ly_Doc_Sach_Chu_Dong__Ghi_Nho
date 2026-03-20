import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_screen.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _email = '';
  String? _avatarUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _email = user.email ?? '';
        final data = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null && mounted) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _bioController.text = data['bio'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _avatarUrl = data['avatar_url'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus(); // close keyboard

    setState(() {
      _isSaving = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('users').update({
          'name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          'phone': _phoneController.text.trim(),
        }).eq('id', user.id);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật thông tin cá nhân!'),
            backgroundColor: Color(0xFF4A745B),
          ),
        );
        ref.invalidate(userProfileProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu thông tin: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);

      if (pickedFile == null) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'Bạn chưa đăng nhập!';

      final file = File(pickedFile.path);
      final fileExtension = pickedFile.path.split('.').last;
      final path = 'avatars/${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await Supabase.instance.client.storage
          .from('avatars')
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      final avatarUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(path);

      await Supabase.instance.client.from('users').update({
        'avatar_url': avatarUrl,
      }).eq('id', user.id);

      // Báo cho Màn Cá nhân cập nhật dữ liệu lập tức
      ref.invalidate(userProfileProvider);

      if (mounted) {
        setState(() {
          _avatarUrl = avatarUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi ảnh đại diện thành công!'), backgroundColor: Color(0xFF4A745B)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  Future<void> _deleteAccount() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    
    // Hiện loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F))),
    );
    
    try {
      // 1. Xóa dữ liệu user trong bảng users (Các bảng khác cần set cascade delete trên db)
      await Supabase.instance.client.from('users').delete().eq('id', user.id);
      
      // 2. Thử gọi RPC xóa Auth User nếu Supabase đã cài đặt hàm này (không bắt buộc)
      try {
        await Supabase.instance.client.rpc('delete_user');
      } catch (_) {}
      
      // 3. Đăng xuất để xóa session hiện tại
      await Supabase.instance.client.auth.signOut();
      
      if (!mounted) return;
      Navigator.pop(context); // Đóng loading dialog
      
      // Quay về trang gốc (AuthWrapper sẽ tự bắt tín hiệu signOut để chuyển về Login)
      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xóa tài khoản: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cảnh báo xóa tài khoản', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontFamily: 'Serif')),
          content: const Text('Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản này không? Mọi dữ liệu (sách, ghi chú, tiến độ học) sẽ bị xóa sạch và không thể khôi phục.', style: TextStyle(fontSize: 14)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context); // Đóng popup xác nhận
                _deleteAccount(); // Chạy hàm xóa
              },
              child: const Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        title: const Text('Tài khoản', style: TextStyle(color: Color(0xFF38684A), fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Serif')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF38684A)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A745B)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: const Color(0xFF1976D2), // Blue avatar placeholder
                            backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty 
                                ? NetworkImage(_avatarUrl!) 
                                : null,
                            child: _avatarUrl == null || _avatarUrl!.isEmpty
                                ? Text(
                                    _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'A',
                                    style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ),
                        if (_isUploadingAvatar)
                          const Positioned.fill(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        GestureDetector(
                          onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A745B),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFF8F6F0), width: 3),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Thay đổi ảnh đại diện',
                    style: TextStyle(color: Color(0xFF4A745B), fontWeight: FontWeight.bold, fontSize: 14),
                  ),

                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Thông cá nhân', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EFE9), // Light beige
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildEditableRow('Họ tên', _nameController, hint: 'Nhập họ tên'),
                        _buildDivider(),
                        _buildEditableRow('Giới thiệu', _bioController, hint: 'Chưa cập nhật'),
                        _buildDivider(),
                        _buildLockedRow('Email', _email.isNotEmpty ? _email : 'Chưa có email'),
                        _buildDivider(),
                        _buildEditableRow('Số điện thoại', _phoneController, hint: 'Nhập số ĐT', isNumber: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A745B),
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: _confirmDeleteAccount,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Text on left, icon on right like image
                        children: const [
                          Text('Xóa Tài Khoản', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 15)),
                          Icon(Icons.delete_outline, color: Color(0xFFD32F2F), size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller, {String hint = '', bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B263B))),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
              style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B263B))),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.lock_outline, size: 14, color: Color(0xFFD32F2F)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.white, thickness: 1.5);
  }
}
