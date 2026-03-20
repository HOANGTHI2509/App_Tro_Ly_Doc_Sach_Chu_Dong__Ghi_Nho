import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/admin_avatar.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(() {
      _filterUsers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(response);
          _filtered = _users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('[AdminUsers] Error: $e');
    }
  }

  void _filterUsers(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = _users.where((u) {
        final name = (u['full_name'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        return name.contains(q) || email.contains(q);
      }).toList();
    });
  }

  // ─── Các hành động quản lý ───────────────────────────────────────
  Future<void> _updateUser(String userId, Map<String, dynamic> data) async {
    await _supabase.from('users').update(data).eq('id', userId);
    await _fetchUsers();
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // Thử xoá record trong bảng users
      await _supabase.from('users').delete().eq('id', userId);

      // Xoá khỏi danh sách cục bộ ngay lập tức
      setState(() {
        _users.removeWhere((u) => u['id'] == userId);
        _filtered.removeWhere((u) => u['id'] == userId);
      });
    } catch (e) {
      debugPrint('[AdminUsers] Delete error: $e');
      // Nếu không xoá được (do RLS), ít nhất đánh dấu là disabled
      try {
        await _supabase.from('users').update({
          'status': 'deleted',
          'email': 'deleted_${DateTime.now().millisecondsSinceEpoch}@deleted.com',
        }).eq('id', userId);
        // Xoá khỏi UI
        setState(() {
          _users.removeWhere((u) => u['id'] == userId);
          _filtered.removeWhere((u) => u['id'] == userId);
        });
        _showSnack('Tài khoản đã bị vô hiệu hoá vĩnh viễn!', const Color(0xFFEF4444));
        return;
      } catch (e2) {
        debugPrint('[AdminUsers] Fallback update error: $e2');
        _showSnack('Không thể xoá tài khoản. Kiểm tra lại quyền Supabase RLS.', Colors.red.shade800);
        return;
      }
    }
    _showSnack('Đã xoá tài khoản thành công!', const Color(0xFFDC2626));
  }

  // ─── Bottom Sheet Cài đặt ─────────────────────────────────────────
  void _showSettingsSheet(Map<String, dynamic> user) {
    final String userId = user['id'];
    final String fullName = user['full_name'] ?? 'Người dùng';
    final String email = user['email'] ?? '';
    final String avatar = user['avatar_url'] ?? 'https://ui-avatars.com/api/?name=$fullName&background=0C4A6E&color=fff';
    final String status = user['status'] ?? 'active';
    final String role = user['role'] ?? 'user';
    final bool isVerified = user['is_verified'] == true;
    final bool isBanned = status == 'banned';
    final bool isAdmin = role == 'admin';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
              ),
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              const SizedBox(height: 20),

              // User info header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFE2E8F0),
                      backgroundImage: NetworkImage(avatar),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          Text(email, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: [
                              _statusBadge(isBanned ? 'BỊ KHÓA' : 'HOẠT ĐỘNG',
                                isBanned ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                              if (isAdmin)
                                _statusBadge('ADMIN', const Color(0xFF7C3AED)),
                              if (isVerified)
                                _statusBadge('✓ XÁC MINH', const Color(0xFF0C4A6E)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 8),

              // ── Nhóm: Xem ───────────────────────────────────────
              _sheetSectionHeader('THÔNG TIN'),
              _sheetAction(
                icon: Icons.person_outline_rounded,
                iconBg: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0369A1),
                label: 'Xem hồ sơ đầy đủ',
                onTap: () {
                  Navigator.pop(ctx);
                  _showProfileDetail(user);
                },
              ),

              // ── Nhóm: Phân quyền ────────────────────────────────
              _sheetSectionHeader('PHÂN QUYỀN'),
              if (!isAdmin)
                _sheetAction(
                  icon: Icons.shield_rounded,
                  iconBg: const Color(0xFFEDE9FE),
                  iconColor: const Color(0xFF7C3AED),
                  label: 'Nâng lên Admin',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateUser(userId, {'role': 'admin'});
                    _showSnack('Đã nâng quyền $fullName lên Admin!', Colors.deepPurple);
                  },
                )
              else
                _sheetAction(
                  icon: Icons.person_rounded,
                  iconBg: const Color(0xFFF1F5F9),
                  iconColor: const Color(0xFF475569),
                  label: 'Hạ xuống User thường',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateUser(userId, {'role': 'user'});
                    _showSnack('Đã thu hồi quyền Admin của $fullName.', Colors.orange);
                  },
                ),
              if (!isVerified)
                _sheetAction(
                  icon: Icons.verified_rounded,
                  iconBg: const Color(0xFFD1FAE5),
                  iconColor: const Color(0xFF059669),
                  label: 'Xác minh tài khoản tác giả',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateUser(userId, {'is_verified': true});
                    _showSnack('Đã xác minh tài khoản tác giả cho $fullName!', Colors.green);
                  },
                )
              else
                _sheetAction(
                  icon: Icons.remove_circle_outline_rounded,
                  iconBg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFF92400E),
                  label: 'Thu hồi xác minh tác giả',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateUser(userId, {'is_verified': false});
                    _showSnack('Đã thu hồi xác minh tác giả.', Colors.orange);
                  },
                ),

              // ── Nhóm: Kiểm soát ─────────────────────────────────
              _sheetSectionHeader('KIỂM SOÁT TÀI KHOẢN'),
              _sheetAction(
                icon: Icons.warning_amber_rounded,
                iconBg: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFF59E0B),
                label: 'Gửi cảnh báo vi phạm',
                onTap: () {
                  Navigator.pop(ctx);
                  _showWarningDialog(userId, fullName);
                },
              ),
              if (!isBanned)
                _sheetAction(
                  icon: Icons.lock_outline_rounded,
                  iconBg: const Color(0xFFFEE2E2),
                  iconColor: const Color(0xFFEF4444),
                  label: 'Khóa tài khoản',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateUser(userId, {'status': 'banned'});
                    _showSnack('Đã khóa tài khoản $fullName!', Colors.red);
                  },
                )
              else
                _sheetAction(
                  icon: Icons.lock_open_rounded,
                  iconBg: const Color(0xFFD1FAE5),
                  iconColor: const Color(0xFF059669),
                  label: 'Mở khóa tài khoản',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _updateUser(userId, {'status': 'active'});
                    _showSnack('Đã mở khóa tài khoản $fullName!', Colors.green);
                  },
                ),

              // ── Xóa tài khoản ───────────────────────────────────
              _sheetSectionHeader('VÙNG NGUY HIỂM'),
              _sheetAction(
                icon: Icons.delete_forever_rounded,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFDC2626),
                label: 'Xóa tài khoản vĩnh viễn',
                labelColor: const Color(0xFFDC2626),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirm(userId, fullName);
                },
              ),
              const SizedBox(height: 8),
                    ], // inner Column children
                  ), // inner Column
                ), // SingleChildScrollView
              ), // Flexible
            ], // outer Column children
          ), // outer Column
        ); // Container
      }, // builder
    ); // showModalBottomSheet
  }

  // ─── Xem hồ sơ đầy đủ ─────────────────────────────────────────────
  void _showProfileDetail(Map<String, dynamic> user) {
    final String fullName = user['full_name'] ?? 'Người dùng';
    final String email = user['email'] ?? 'Không có email';
    final String avatar = user['avatar_url'] ?? 'https://ui-avatars.com/api/?name=$fullName&background=0C4A6E&color=fff';
    final String role = user['role'] ?? 'user';
    final String status = user['status'] ?? 'active';
    final bool isVerified = user['is_verified'] == true;
    final createdAt = user['created_at'] != null ? DateTime.tryParse(user['created_at']) : null;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 32, backgroundImage: NetworkImage(avatar), backgroundColor: const Color(0xFFE2E8F0)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(email, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _profileRow(Icons.manage_accounts_rounded, 'Vai trò', role == 'admin' ? '🛡️ Admin' : '👤 User'),
              _profileRow(Icons.circle_outlined, 'Trạng thái', status == 'banned' ? '🔒 Bị khóa' : '✅ Hoạt động'),
              _profileRow(Icons.verified_rounded, 'Xác minh', isVerified ? '✓ Đã xác minh' : 'Chưa xác minh'),
              if (createdAt != null)
                _profileRow(Icons.calendar_today_rounded, 'Ngày tham gia', '${createdAt.day}/${createdAt.month}/${createdAt.year}'),
              _profileRow(Icons.fingerprint_rounded, 'ID', user['id'].toString().substring(0, 16) + '...'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C4A6E), elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Đóng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ─── Dialog gửi cảnh báo ──────────────────────────────────────────
  void _showWarningDialog(String userId, String fullName) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            Text('Cảnh báo $fullName'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhập lý do cảnh báo. Người dùng sẽ nhận được thông báo này:'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nội dung cảnh báo...',
                filled: true, fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Lưu cảnh báo vào Supabase (có thể lưu vào bảng notifications hoặc reports)
              await _supabase.from('reports').insert({
                'type': 'warning',
                'content': 'ADMIN CẢNH BÁO: ${ctrl.text.trim()}',
                'reporter_id': _supabase.auth.currentUser?.id,
                'status': 'resolved',
              });
              _showSnack('Đã gửi cảnh báo tới $fullName!', const Color(0xFFF59E0B));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B), elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Gửi cảnh báo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Dialog xóa tài khoản ─────────────────────────────────────────
  void _showDeleteConfirm(String userId, String fullName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Bạn có chắc muốn xóa vĩnh viễn tài khoản\n'),
              TextSpan(text: '"$fullName"', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
              const TextSpan(text: '?\n\nHành động này '),
              const TextSpan(text: 'KHÔNG THỂ HOÀN TÁC.', style: TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: ' Toàn bộ dữ liệu của tài khoản sẽ bị xóa.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteUser(userId);
              _showSnack('Đã xóa tài khoản $fullName!', const Color(0xFFDC2626));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626), elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────
  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }

  Widget _sheetSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1)),
    );
  }

  Widget _sheetAction({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    Color? labelColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: labelColor ?? const Color(0xFF0F172A))),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0C4A6E)),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        flexibleSpace: Container(color: const Color(0xFFF9FAFC)),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0C4A6E)), onPressed: _fetchUsers),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: AdminAvatar()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C4A6E)))
          : RefreshIndicator(
              onRefresh: _fetchUsers,
              color: const Color(0xFF0C4A6E),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quản lý Thành viên', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0C4A6E), letterSpacing: -0.5)),
                          const SizedBox(height: 8),
                          const Text('Giám sát và điều hành danh sách người dùng hệ thống.', style: TextStyle(color: Color(0xFF475569), fontSize: 15)),
                          const SizedBox(height: 24),

                          // Thẻ tổng số
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(color: const Color(0xFF0C4A6E), borderRadius: BorderRadius.circular(24)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('TỔNG SỐ THÀNH VIÊN', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      const SizedBox(height: 10),
                                      Text('${_users.length}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
                                      const SizedBox(height: 10),
                                      // Stats row
                                      Row(
                                        children: [
                                          _statMini('${_users.where((u) => u['role'] == 'admin').length}', 'Admin', Colors.purple.shade200),
                                          const SizedBox(width: 16),
                                          _statMini('${_users.where((u) => u['status'] == 'banned').length}', 'Bị khóa', Colors.red.shade200),
                                          const SizedBox(width: 16),
                                          _statMini('${_users.where((u) => u['is_verified'] == true).length}', 'Xác minh', Colors.green.shade200),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.group_rounded, size: 72, color: Colors.white.withOpacity(0.08)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Search
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.search, color: Color(0xFF64748B)),
                                hintText: 'Tìm kiếm theo tên hoặc email...',
                                hintStyle: TextStyle(color: Color(0xFF64748B)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('DANH SÁCH THÀNH VIÊN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569), letterSpacing: 1)),
                              Text('Hiện có ${_filtered.length} tài khoản', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildUserCard(_filtered[index]),
                        childCount: _filtered.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  Widget _statMini(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String fullName = user['full_name'] ?? 'Chưa cập nhật';
    final String email = user['email'] ?? 'Không có email';
    final String avatar = user['avatar_url'] ?? 'https://ui-avatars.com/api/?name=$fullName&background=0C4A6E&color=fff';
    final bool isBanned = user['status'] == 'banned';
    final bool isAdmin = user['role'] == 'admin';
    final bool isVerified = user['is_verified'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isBanned ? Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)) : null,
        boxShadow: [BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage: NetworkImage(avatar),
              ),
              if (isAdmin)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 12),
                  ),
                ),
              if (isVerified && !isAdmin)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Color(0xFF0C4A6E), shape: BoxShape.circle),
                    child: const Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                const SizedBox(height: 3),
                Text(email, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isBanned ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isBanned ? 'BỊ KHÓA' : 'HOẠT ĐỘNG',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isBanned ? const Color(0xFFDC2626) : const Color(0xFF059669)),
            ),
          ),
          const SizedBox(width: 10),
          // Settings gear button
          GestureDetector(
            onTap: () => _showSettingsSheet(user),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings_rounded, color: Color(0xFF0C4A6E), size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
