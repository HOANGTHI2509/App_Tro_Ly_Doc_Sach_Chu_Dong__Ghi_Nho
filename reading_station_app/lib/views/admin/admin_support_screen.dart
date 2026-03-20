import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/admin_avatar.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  final _supabase = Supabase.instance.client;

  int _activeTab = 0; // 0 = Tickets, 1 = Feedback
  bool _isLoading = true;
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _feedbacks = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAll();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    await Future.wait([_fetchTickets(), _fetchFeedbacks()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchTickets() async {
    try {
      // Lấy các báo cáo dạng ticket hỗ trợ từ bảng reports
      final data = await _supabase
          .from('reports')
          .select('*, reporter:reporter_id(full_name, avatar_url)')
          .inFilter('type', ['support', 'feedback', 'bug'])
          .order('created_at', ascending: false);

      _tickets = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('[Support] Error fetching tickets: $e');
      _tickets = [];
    }
  }

  Future<void> _fetchFeedbacks() async {
    try {
      // Lấy các báo cáo dạng góp ý từ bảng reports
      final data = await _supabase
          .from('reports')
          .select('*, reporter:reporter_id(full_name, avatar_url)')
          .inFilter('type', ['feature_request', 'improvement', 'suggestion'])
          .order('created_at', ascending: false);

      _feedbacks = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('[Support] Error fetching feedbacks: $e');
      _feedbacks = [];
    }
  }

  String _getTimeAgo(String? isoDate) {
    if (isoDate == null) return 'N/A';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return 'N/A';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'pending': return 'ĐANG CHỜ';
      case 'resolved': return 'ĐÃ XỬ LÝ';
      case 'dismissed': return 'ĐÃ ĐÓNG';
      default: return 'ĐANG CHỜ';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'resolved': return const Color(0xFF10B981);
      case 'dismissed': return const Color(0xFF94A3B8);
      default: return const Color(0xFFF59E0B);
    }
  }

  /// Cập nhật trạng thái báo cáo
  Future<void> _updateStatus(String id, String newStatus) async {
    await _supabase.from('reports').update({'status': newStatus}).eq('id', id);
    await _fetchAll();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã cập nhật trạng thái thành công!')),
    );
  }

  /// Hiển thị popup phản hồi / trả lời
  void _showReplyDialog(Map<String, dynamic> item) {
    final controller = TextEditingController();
    final authorName = (item['reporter'] as Map<String, dynamic>?)?['full_name'] ?? 'Người dùng';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.reply_rounded, color: Color(0xFF0C4A6E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Phản hồi tới $authorName',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C4A6E)),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              // Nội dung gốc
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  item['content'] ?? '',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontStyle: FontStyle.italic),
                  maxLines: 3, overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung phản hồi...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0C4A6E))),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        // Đánh dấu đã xử lý
                        await _updateStatus(item['id'], 'resolved');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã gửi phản hồi và đánh dấu xử lý!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C4A6E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Gửi phản hồi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        flexibleSpace: Container(color: const Color(0xFFF8FAFC)),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0C4A6E)),
            onPressed: _fetchAll,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: AdminAvatar()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C4A6E)))
          : RefreshIndicator(
              onRefresh: _fetchAll,
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
                          const Text('Hỗ trợ & Góp ý', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0C4A6E))),
                          const SizedBox(height: 8),
                          const Text('Xử lý yêu cầu hỗ trợ và đóng góp từ người dùng.', style: TextStyle(color: Color(0xFF64748B))),
                          const SizedBox(height: 24),

                          // Tab buttons
                          Row(
                            children: [
                              _buildTab('Ticket hỗ trợ (${_tickets.length})', 0),
                              const SizedBox(width: 24),
                              _buildTab('Góp ý tính năng (${_feedbacks.length})', 1),
                            ],
                          ),
                          const Divider(color: Color(0xFFE2E8F0), thickness: 1.5, height: 1),
                          const SizedBox(height: 24),

                          // Search Box
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
                                icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                                hintText: 'Tìm kiếm theo nội dung hoặc tên...',
                                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Content based on active tab
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: _activeTab == 0
                        ? _buildTicketList()
                        : _buildFeedbackList(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? const Color(0xFF0C4A6E) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isActive ? 70 : 0,
            color: const Color(0xFF0C4A6E),
          ),
        ],
      ),
    );
  }

  SliverList _buildTicketList() {
    final filtered = _tickets.where((t) {
      if (_searchQuery.isEmpty) return true;
      final content = (t['content'] ?? '').toString().toLowerCase();
      final name = ((t['reporter'] as Map?)?['full_name'] ?? '').toString().toLowerCase();
      return content.contains(_searchQuery) || name.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([_buildEmpty('Chưa có ticket hỗ trợ nào')]),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = filtered[index];
          final authorName = (item['reporter'] as Map<String, dynamic>?)?['full_name'] ?? 'Người dùng';
          final id = '#TK-${item['id'].toString().substring(0, 6).toUpperCase()}';
          final status = item['status'] as String?;
          final isPending = status == 'pending';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTicketCard(
              id: id,
              status: _statusLabel(status),
              statusColor: _statusColor(status),
              title: item['content'] ?? 'Không có tiêu đề',
              author: authorName,
              time: _getTimeAgo(item['created_at']),
              isPending: isPending,
              onReply: () => _showReplyDialog(item),
              onClose: isPending ? () => _updateStatus(item['id'], 'dismissed') : null,
            ),
          );
        },
        childCount: filtered.length,
      ),
    );
  }

  SliverList _buildFeedbackList() {
    final filtered = _feedbacks.where((f) {
      if (_searchQuery.isEmpty) return true;
      final content = (f['content'] ?? '').toString().toLowerCase();
      final name = ((f['reporter'] as Map?)?['full_name'] ?? '').toString().toLowerCase();
      return content.contains(_searchQuery) || name.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([_buildEmpty('Chưa có góp ý nào')]),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = filtered[index];
          final authorName = (item['reporter'] as Map<String, dynamic>?)?['full_name'] ?? 'Người dùng';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFeedbackCard(
              author: authorName,
              content: '"${item['content'] ?? ''}"',
              status: item['status'],
              onReply: () => _showReplyDialog(item),
            ),
          );
        },
        childCount: filtered.length,
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildTicketCard({
    required String id,
    required String status,
    required Color statusColor,
    required String title,
    required String author,
    required String time,
    required bool isPending,
    required VoidCallback onReply,
    VoidCallback? onClose,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(id, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0C4A6E)),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text('Người gửi: $author', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isPending
                    ? ElevatedButton(
                        onPressed: onReply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C4A6E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Phản hồi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    : OutlinedButton(
                        onPressed: onReply,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: const Color(0xFF0C4A6E).withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Xem lại', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0C4A6E))),
                      ),
              ),
              if (onClose != null) ...[
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF475569)),
                    tooltip: 'Đóng ticket',
                    onPressed: onClose,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard({
    required String author,
    required String content,
    String? status,
    required VoidCallback onReply,
  }) {
    final statusColor = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFE2E8F0),
                    backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$author&background=random'),
                    onBackgroundImageError: (_, __) {},
                  ),
                  const SizedBox(width: 10),
                  Text(author, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 15)),
                ],
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(_statusLabel(status), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF475569), height: 1.5, fontSize: 14), maxLines: 4, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onReply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C4A6E),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Trả lời góp ý', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
