import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_support_screen.dart';
import 'admin_users_screen.dart';
import 'widgets/admin_avatar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  int _totalUsers = 0;
  int _pendingSupportTickets = 0;
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchMetrics(),
      _fetchRecentActivities(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchMetrics() async {
    try {
      // Lấy tổng số người dùng
      final usersResponse = await _supabase.from('users').select('id');
      _totalUsers = (usersResponse as List).length;

      // Lấy số hỗ trợ chờ xử lý
      final supportResponse = await _supabase.from('support_requests').select('id').eq('status', 'pending');
      _pendingSupportTickets = (supportResponse as List).length;
    } catch (e) {
      debugPrint('[AdminDashboard] Error fetching metrics: $e');
    }
  }

  Future<void> _fetchRecentActivities() async {
    try {
      // Lấy yêu cầu hỗ trợ gần đây
      final supportReqs = await _supabase
          .from('support_requests')
          .select('id, user_email, title, status, created_at')
          .order('created_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> activities = [];

      for (final req in List<Map<String, dynamic>>.from(supportReqs)) {
        final status = req['status'] ?? 'pending';
        final message = (req['title'] ?? '') as String;
        final createdAt = DateTime.tryParse(req['created_at'] ?? '') ?? DateTime.now();
        final timeAgo = _getTimeAgo(createdAt);
        final userEmail = req['user_email'] ?? 'Ẩn danh';

        IconData icon;
        Color iconColor;
        Color bgColor;
        String title;
        String btnLabel;
        bool btnSolid;

        if (status == 'pending') {
          icon = Icons.mark_email_unread_rounded;
          iconColor = const Color(0xFFEA580C);
          bgColor = const Color(0xFFFFEDD5);
          title = 'Từ $userEmail';
          btnLabel = 'Xem ngay';
          btnSolid = true;
        } else {
          icon = Icons.mark_email_read_rounded;
          iconColor = const Color(0xFF10B981);
          bgColor = const Color(0xFFD1FAE5);
          title = 'Đã xử lý: $userEmail';
          btnLabel = 'Xem';
          btnSolid = false;
        }

        activities.add({
          'id': req['id'],
          'icon': icon,
          'iconColor': iconColor,
          'bgColor': bgColor,
          'title': title,
          'subtitle': message.length > 40 ? '${message.substring(0, 40)}...' : message,
          'time': timeAgo,
          'btnLabel': btnLabel,
          'btnColor': status == 'pending' ? iconColor : const Color(0xFF0C4A6E),
          'btnSolid': btnSolid,
          'status': status,
        });
      }
      _recentActivities = activities;
    } catch (e) {
      debugPrint('[AdminDashboard] Error fetching activities: $e');
      _recentActivities = [];
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}p trước';
    if (diff.inHours < 24) return '${diff.inHours}h trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _navigateToSupport() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdminSupportScreen()),
    );
  }

  void _navigateToUsers() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
    );
  }



  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0C4A6E))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        flexibleSpace: Container(color: const Color(0xFFF9FAFC)),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const AdminAvatar(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C4A6E)))
          : RefreshIndicator(
              onRefresh: _fetchAllData,
              color: const Color(0xFF0C4A6E),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                children: [
                  const Text('Tổng quan', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0C4A6E), letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text('Cập nhật hoạt động hệ thống ngày hôm nay.', style: TextStyle(color: Color(0xFF475569), fontSize: 15)),
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _navigateToUsers,
                          child: _buildStatCard(
                            'NGƯỜI DÙNG', 
                            '$_totalUsers', 
                            '+', 
                            const Color(0xFF10B981),
                            true
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: _navigateToSupport,
                          child: _buildStatCard(
                            'YÊU CẦU HỖ TRỢ', 
                            _pendingSupportTickets.toString().padLeft(2, '0'), 
                            'CHỜ DUYỆT', 
                            const Color(0xFFEA580C),
                            false
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Hoạt động hỗ trợ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0C4A6E))),
                      GestureDetector(
                        onTap: _navigateToSupport,
                        child: const Text('Xem tất cả', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Activity List - Dữ liệu thực từ Supabase
                  if (_recentActivities.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          const Text('Chưa có hoạt động nào', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
                        ],
                      ),
                    )
                  else
                    ...List.generate(_recentActivities.length, (index) {
                      final activity = _recentActivities[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < _recentActivities.length - 1 ? 16 : 0),
                        child: _buildActivityCard(
                          activity['icon'] as IconData,
                          activity['iconColor'] as Color,
                          activity['bgColor'] as Color,
                          activity['title'] as String,
                          activity['subtitle'] as String,
                          activity['time'] as String,
                          hasButton: true,
                          btnLabel: activity['btnLabel'] as String,
                          btnColor: activity['btnColor'] as Color,
                          btnSolid: activity['btnSolid'] as bool,
                          onPressed: _navigateToSupport,
                        ),
                      );
                    }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, String badge, Color badgeColor, bool isChart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1, color: Color(0xFF475569))),
              if (!isChart)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                   decoration: BoxDecoration(color: badgeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                   child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                 ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0C4A6E), height: 1)),
              const SizedBox(width: 8),
              if (isChart)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w800)),
                )
            ],
          ),
          const SizedBox(height: 24),
          if (isChart)
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                 _miniBar(12, badgeColor),
                 _miniBar(16, badgeColor),
                 _miniBar(20, badgeColor),
                 _miniBar(16, badgeColor),
                 _miniBar(24, badgeColor),
                 _miniBar(32, badgeColor),
               ],
             )
          else
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Stack(
                   children: [
                     Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4))),
                     Container(height: 6, width: 80, decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4))),
                   ],
                 ),
                 const SizedBox(height: 8),
                 const Text('80% mục tiêu xử lý', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
               ],
             ),
        ],
      ),
    );
  }

  Widget _miniBar(double height, Color color) {
    return Container(
      width: 14,
      height: height,
      decoration: BoxDecoration(color: color.withOpacity(height > 20 ? 1 : 0.4), borderRadius: BorderRadius.circular(4)),
    );
  }

  Widget _buildActivityCard(
    IconData icon, Color iconColor, Color bgColor, String title, String subtitle, String time, 
    {bool hasButton = false, String btnLabel = '', Color btnColor = Colors.white, bool btnSolid = false, VoidCallback? onPressed}
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0C4A6E)))),
                        Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Color(0xFF475569), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          if (hasButton) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: btnSolid
                 ? ElevatedButton(
                     onPressed: onPressed,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: btnColor,
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       elevation: 0,
                     ),
                     child: Text(btnLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                   )
                 : OutlinedButton(
                     onPressed: onPressed,
                     style: OutlinedButton.styleFrom(
                       foregroundColor: btnColor,
                       side: BorderSide(color: btnColor.withOpacity(0.2)),
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     ),
                     child: Text(btnLabel, style: TextStyle(color: btnColor, fontWeight: FontWeight.bold, fontSize: 12)),
                   ),
            ),
          ]
        ],
      ),
    );
  }
}
