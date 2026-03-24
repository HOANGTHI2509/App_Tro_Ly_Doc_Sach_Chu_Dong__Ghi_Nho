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
  List<Map<String, dynamic>> _chats = [];
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
    await Future.wait([_fetchTickets(), _fetchChats()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchTickets() async {
    try {
      final data = await _supabase
          .from('support_requests')
          .select()
          .order('created_at', ascending: false);

      _tickets = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('[Support] Error fetching tickets: $e');
      _tickets = [];
    }
  }

  Future<void> _fetchChats() async {
    try {
      final data = await _supabase
          .from('support_messages')
          .select()
          .order('created_at', ascending: false);

      List<dynamic> usersData = [];
      try {
        usersData = await _supabase.from('users').select('id, name, avatar_url');
      } catch (e) {
        // ignore if table users doesn't exist
      }
      final usersMap = {for (var u in usersData) u['id']: u};

      final messages = List<Map<String, dynamic>>.from(data);
      final Map<String, Map<String, dynamic>> latestMessages = {};
      for (var msg in messages) {
         final uId = msg['user_id'] as String;
         if (!latestMessages.containsKey(uId)) {
            final uInfo = usersMap[uId] as Map<String, dynamic>? ?? {};
            msg['user_name'] = uInfo['name'] ?? 'Người dùng ${uId.substring(0, 6)}';
            msg['avatar_url'] = uInfo['avatar_url'];
            latestMessages[uId] = msg;
         }
      }
      _chats = latestMessages.values.toList();
    } catch (e) {
      debugPrint('[Support] Error fetching chats: $e');
      _chats = [];
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
      case 'resolved': return 'ĐÃ ĐÓNG';
      case 'dismissed': return 'ĐÃ ĐÓNG';
      default: return 'ĐANG CHỜ';
    }
  }

  Color _statusBgColor(String? status) {
    switch (status) {
      case 'pending': return const Color(0xFFFDE6C8); 
      case 'resolved': return const Color(0xFFD6E4F0); 
      case 'dismissed': return const Color(0xFFD6E4F0);
      default: return const Color(0xFFFDE6C8);
    }
  }

  Color _statusTextColor(String? status) {
    switch (status) {
      case 'pending': return const Color(0xFF9E631F); // Brown
      case 'resolved': return const Color(0xFF5A7285); // Blue grey
      case 'dismissed': return const Color(0xFF5A7285);
      default: return const Color(0xFF9E631F);
    }
  }

  /// Cập nhật trạng thái báo cáo
  Future<void> _updateStatus(String id, String newStatus) async {
    await _supabase.from('support_requests').update({'status': newStatus}).eq('id', id);
    await _fetchAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật trạng thái thành công!')),
      );
    }
  }

  /// Hiển thị popup đóng ticket (với email support thì không rep mà chỉ update status do chưa có hệ thống email push)
  void _showReplyDialog(Map<String, dynamic> item) {
    final TextEditingController replyController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text('Phản hồi Email', style: TextStyle(color: Color(0xFF0C4A6E), fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Người gửi: ${item['name']} (${item['email']})', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                   const SizedBox(height: 8),
                   Text('Tiêu đề: ${item['subject']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                   const SizedBox(height: 12),
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text('Nội dung báo cáo:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569), fontSize: 13)),
                         const SizedBox(height: 4),
                         Text(item['message'] ?? '', style: const TextStyle(color: Color(0xFF333333), height: 1.5)),
                       ],
                     ),
                   ),
                   const SizedBox(height: 16),
                   if (item['status'] == 'resolved' || item['status'] == 'dismissed') ...[
                      const Text('Nội dung bạn đã phản hồi:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0C4A6E))),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
                        child: Text(item['admin_reply'] ?? '(Không có nội dung phản hồi)', style: const TextStyle(color: Color(0xFF334155))),
                      )
                   ] else ...[
                     TextField(
                       controller: replyController,
                       maxLines: 5,
                       decoration: InputDecoration(
                         hintText: 'Nhập nội dung phản hồi...',
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                         filled: true,
                         fillColor: const Color(0xFFF8FAFC)
                       ),
                     )
                   ]
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(item['status'] == 'resolved' ? 'Đóng' : 'Hủy', style: const TextStyle(color: Colors.grey))),
              if (item['status'] != 'resolved' && item['status'] != 'dismissed')
                ElevatedButton(
                  onPressed: isSending ? null : () async {
                    if (replyController.text.trim().isEmpty) return;
                    setStateSB(() => isSending = true);
                    
                    // Mô phỏng hiệu ứng xử lý gửi mail
                    await Future.delayed(const Duration(seconds: 1));
                    
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      // Update with admin_reply field
                      await _supabase.from('support_requests').update({
                        'status': 'resolved',
                        'admin_reply': replyController.text.trim(),
                      }).eq('id', item['id']);
                      await _fetchAll();
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã gửi phản hồi và đóng Ticket thành công!')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C4A6E)),
                  child: isSending 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Gửi & Đóng', style: TextStyle(color: Colors.white)),
                )
            ],
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        flexibleSpace: Container(color: const Color(0xFFF8FAFC)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0C4A6E)),
          onPressed: () => Navigator.pop(context),
        ),
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
                              _buildTab('Email hỗ trợ (${_tickets.length})', 0),
                              const SizedBox(width: 24),
                              _buildTab('Chat trực tuyến (${_chats.length})', 1),
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
                        : _buildChatList(),
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
      final content = (t['message'] ?? '').toString().toLowerCase();
      final name = (t['name'] ?? '').toString().toLowerCase();
      return content.contains(_searchQuery) || name.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([_buildEmpty('Chưa có email hỗ trợ nào')]),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = filtered[index];
          final authorName = item['name'] ?? 'Người dùng';
          final email = item['email'] ?? '';
          final subject = item['subject'] ?? '';
          final message = item['message'] ?? '';
          final id = '#EM-${item['id'].toString().substring(0, 6).toUpperCase()}';
          final status = item['status'] as String?;
          final isPending = status == 'pending';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTicketCard(
              id: id,
              status: _statusLabel(status),
              statusBgColor: status == 'pending' ? const Color(0xFFFDE6C8) : const Color(0xFFD7E5EF),
              statusTextColor: status == 'pending' ? const Color(0xFF9E631F) : const Color(0xFF5A7285),
              title: '[$subject] $message',
              author: '$authorName', // Based on image: Người gửi: Lê Minh Tâm
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

  SliverList _buildChatList() {
    final filtered = _chats.where((f) {
      if (_searchQuery.isEmpty) return true;
      final content = (f['message'] ?? '').toString().toLowerCase();
      final name = (f['user_name'] ?? '').toString().toLowerCase();
      return content.contains(_searchQuery) || name.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([_buildEmpty('Chưa có tin nhắn chat nào')]),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = filtered[index];
          final uId = item['user_id'] as String;
          final userName = item['user_name'] ?? 'Người dùng';
          final avatarUrl = item['avatar_url'] as String?;
          final isFromUser = item['is_from_user'] == true;
          final message = item['message'] ?? '';
          final time = _getTimeAgo(item['created_at']);

          return InkWell(
            onTap: () async {
               await Navigator.push(context, MaterialPageRoute(builder: (_) => AdminChatScreen(userId: uId, userName: userName, avatarUrl: avatarUrl)));
               _fetchAll();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                   CircleAvatar(
                     radius: 28,
                     backgroundColor: const Color(0xFFE2E8F0),
                     backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : NetworkImage('https://ui-avatars.com/api/?name=$userName&background=random'),
                   ),
                   const SizedBox(width: 14),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Expanded(child: Text(userName, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 18, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                             Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                           ]
                         ),
                         const SizedBox(height: 6),
                         Row(
                           children: [
                             if (!isFromUser) const Text('Bạn: ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15)),
                             Expanded(child: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isFromUser ? const Color(0xFF334155) : const Color(0xFF94A3B8), fontSize: 15, fontWeight: isFromUser ? FontWeight.w500 : FontWeight.normal))),
                           ]
                         ),
                       ]
                     ),
                   ),
                ]
              )
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
    required Color statusBgColor,
    required Color statusTextColor,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(id, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(4)),
                    child: Text(status, style: TextStyle(color: statusTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Text(time, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0C4A6E)),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text('Người gửi: $author', style: const TextStyle(color: Color(0xFF475569), fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: isPending
                    ? ElevatedButton(
                        onPressed: onReply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003D4C),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Phản hồi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                      )
                    : OutlinedButton(
                        onPressed: onReply,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF003D4C)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Xem lại', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003D4C), fontSize: 14)),
                      ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                child: IconButton(
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF4B5563)),
                  onPressed: onClose ?? () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminChatScreen extends StatefulWidget {
  final String userId;
  final String? userName;
  final String? avatarUrl;
  const AdminChatScreen({super.key, required this.userId, this.userName, this.avatarUrl});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Stream<List<Map<String, dynamic>>> _messagesStream;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messagesStream = Supabase.instance.client
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('user_id', widget.userId)
        .order('created_at', ascending: true);
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final txt = _msgController.text.trim();
    if (txt.isEmpty) return;
    _msgController.clear();
    setState(() => _isSending = true);

    try {
      await Supabase.instance.client.from('support_messages').insert({
        'user_id': widget.userId,
        'message': txt,
        'is_from_user': false,
      });
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C4A6E),
        title: Text('Chat với ${widget.userName ?? 'Người dùng'}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (ctx, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final msgs = snapshot.data ?? [];
                
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (ctx, idx) {
                    final isUser = msgs[idx]['is_from_user'] == true;
                    final timeText = _formatTime(msgs[idx]['created_at']);
                    // For admin, if is_from_user = true, it's on left side. If false (admin sent it), it's right.
                    return Align(
                      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.white : const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(msgs[idx]['message'] ?? '', style: const TextStyle(color: Color(0xFF334155), fontSize: 15)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                            child: Text(timeText, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          ),
                        ]
                      ),
                    );
                  }
                );
              }
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn phản hồi...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16)
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSending ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()) : const Icon(Icons.send_rounded, color: Color(0xFF0C4A6E)),
                  onPressed: _isSending ? null : _sendMessage,
                )
              ],
            )
          )
        ],
      )
    );
  }
}

