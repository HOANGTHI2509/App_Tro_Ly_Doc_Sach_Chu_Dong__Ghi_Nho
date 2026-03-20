import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/community_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsBottomSheet extends ConsumerStatefulWidget {
  final String activityId;

  const CommentsBottomSheet({Key? key, required this.activityId}) : super(key: key);

  @override
  ConsumerState<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  String? _replyToCommentId;
  String? _replyToUsername;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    final comments = await ref.read(communityControllerProvider.notifier).getComments(widget.activityId);
    setState(() {
      _comments = comments;
      _isLoading = false;
    });
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final parentId = _replyToCommentId;
    // Clear input immediately for better UX
    _commentController.clear();
    setState(() {
      _replyToCommentId = null;
      _replyToUsername = null;
    });

    await ref.read(communityControllerProvider.notifier).commentOnActivity(
      widget.activityId, 
      text,
      parentId: parentId,
    );

    _loadComments(); // Refresh comments list
  }

  String _getRelativeTime(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) return '${duration.inMinutes > 0 ? duration.inMinutes : 1} phút trước';
    if (duration.inHours < 24) return '${duration.inHours} giờ trước';
    return '${duration.inDays} ngày trước';
  }

  Widget _buildCommentTile(Map<String, dynamic> comment, bool isReply) {
    final user = comment['user'] ?? {};
    final userName = user['name'] ?? 'Ai đó';
    final avatarUrl = user['avatar_url'];
    final createdAt = DateTime.tryParse(comment['created_at'] ?? '') ?? DateTime.now();
    final content = comment['content'] ?? '';
    final commentId = comment['id'];

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40 : 16, right: 16, top: 12, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 14 : 18,
            backgroundColor: const Color(0xFFEBE3D5),
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl)
                : NetworkImage('https://ui-avatars.com/api/?name=$userName&background=random'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C3E35)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getRelativeTime(createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      // Nếu comment cũng là reply, thì parent của nó là parent thực sự, hoặc chính nó.
                      _replyToCommentId = comment['parent_id'] ?? commentId;
                      _replyToUsername = userName;
                    });
                    // Focus logic có thể thêm ở đây
                  },
                  child: const Text(
                    'Trả lời',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B7355)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final myAvatarUrl = currentUser?.userMetadata?['avatar_url'];
    final myName = currentUser?.userMetadata?['name'] ?? 'Tôi';

    // Organize comments into threads
    final List<Map<String, dynamic>> parents = _comments.where((c) => c['parent_id'] == null).toList();
    final Map<String, List<Map<String, dynamic>>> repliesMap = {};
    for (var c in _comments) {
      if (c['parent_id'] != null) {
        repliesMap.putIfAbsent(c['parent_id'], () => []).add(c);
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Bình luận', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF385A46))),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                      ? const Center(child: Text('Chưa có bình luận nào. Hãy là người đầu tiên bình luận!', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: parents.length,
                          itemBuilder: (context, index) {
                            final parent = parents[index];
                            final replies = repliesMap[parent['id']] ?? [];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCommentTile(parent, false),
                                ...replies.map((reply) => _buildCommentTile(reply, true)),
                              ],
                            );
                          },
                        ),
            ),
            if (_replyToUsername != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFEBE3D5),
                child: Row(
                  children: [
                    Text('Đang trả lời: ', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                    Text(_replyToUsername!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() {
                        _replyToCommentId = null;
                        _replyToUsername = null;
                      }),
                      child: const Icon(Icons.close, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.only(
                left: 16, 
                right: 16, 
                top: 8, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -2), blurRadius: 4)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFEBE3D5),
                    backgroundImage: myAvatarUrl != null
                        ? NetworkImage(myAvatarUrl)
                        : NetworkImage('https://ui-avatars.com/api/?name=$myName&background=random'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: _replyToUsername != null ? 'Viết câu trả lời...' : 'Thêm bình luận...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF4A745B)),
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
