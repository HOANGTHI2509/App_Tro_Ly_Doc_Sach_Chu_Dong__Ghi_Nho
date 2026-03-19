import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/community_provider.dart';
import 'add_friend_screen.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);
    final friendsAsync = ref.watch(friendsProvider);
    final pendingAsync = ref.watch(pendingRequestsProvider);
    final recommendAsync = ref.watch(friendRecommendationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(feedProvider);
            ref.invalidate(friendsProvider);
            ref.invalidate(pendingRequestsProvider);
            ref.invalidate(friendRecommendationsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vòng tròn tin cậy',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          // Icon bạn bè + badge số
                          friendsAsync.when(
                            data: (friends) => GestureDetector(
                              onTap: () => _showFriendsList(context, ref, friends),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.people, color: Color(0xFFFF5722), size: 28),
                                  Positioned(
                                    top: -6,
                                    right: -10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF5722),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${friends.length}',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFriendScreen()));
                            },
                            icon: const Icon(Icons.person_add_alt_1, color: Color(0xFFFF5722), size: 28),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Lời mời kết bạn đang chờ
                pendingAsync.when(
                  data: (pending) {
                    if (pending.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📬 Lời mời kết bạn (${pending.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          ...pending.map((req) {
                            final friend = req['friend'] ?? {};
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFEBE5)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFFFA6400),
                                    child: Text(
                                      (friend['name'] ?? '?')[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(friend['name'] ?? 'Người dùng', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(friend['email'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      ref.read(communityControllerProvider.notifier).acceptRequest(req['id']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFA6400),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      minimumSize: const Size(70, 32),
                                      elevation: 0,
                                    ),
                                    child: const Text('Chấp nhận', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // ===== FR4.3: Gợi ý Cá nhân hóa =====
                recommendAsync.when(
                  data: (recs) {
                    if (recs.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💡 Gợi ý từ Vòng tròn',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recs.length,
                              itemBuilder: (context, index) {
                                final rec = recs[index];
                                final count = rec['count'] as int;
                                final names = List<String>.from(rec['reader_names'] ?? []);
                                final bookTitle = rec['book_title'] ?? '';
                                final bookAuthor = rec['book_author'] ?? '';
                                final bookImage = rec['book_image_url'] ?? '';

                                return Container(
                                  width: 280,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFF7043).withOpacity(0.1),
                                        const Color(0xFFFFCA28).withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFFFE0B2)),
                                  ),
                                  child: Row(
                                    children: [
                                      if (bookImage.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            bookImage,
                                            width: 60, height: 90, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 60, height: 90,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.book, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              bookTitle,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                              maxLines: 2, overflow: TextOverflow.ellipsis,
                                            ),
                                            if (bookAuthor.isNotEmpty)
                                              Text(
                                                bookAuthor,
                                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFA6400).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '$count người trong Vòng tròn đã đọc',
                                                style: const TextStyle(
                                                  color: Color(0xFFE65100),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              names.join(', '),
                                              style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // ===== FR4.2: Feed Chất lượng =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    '📰 Hoạt động gần đây',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),

                feedAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: Color(0xFFFA6400)),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Lỗi tải feed: $e'),
                  ),
                  data: (activities) {
                    if (activities.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.rss_feed, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có hoạt động nào',
                                style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Thêm sách hoặc kết bạn để xem hoạt động!',
                                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          ...activities.map((activity) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildActivityCard(activity),
                          )),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// FR4.2 - Activity card format theo đúng yêu cầu
  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final user = activity['user'] ?? {};
    final userName = user['name'] ?? 'Ai đó';
    final type = activity['type'] ?? '';
    final bookTitle = activity['book_title'] ?? '';
    final bookAuthor = activity['book_author'] ?? '';
    final bookImage = activity['book_image_url'] ?? '';
    final rating = activity['rating'];
    final noteContent = activity['note_content'];
    final createdAt = DateTime.tryParse(activity['created_at'] ?? '') ?? DateTime.now();

    // Tạo câu mô tả theo đúng yêu cầu FR4.2
    String description;
    IconData typeIcon;
    Color typeColor;

    switch (type) {
      case 'finished_book':
        final stars = rating != null ? ' và đánh giá $rating ⭐' : '';
        description = '$userName vừa đọc xong "$bookTitle"$stars.';
        typeIcon = Icons.check_circle;
        typeColor = Colors.green;
        break;
      case 'added_book':
        description = '$userName vừa thêm "$bookTitle" vào kệ "Muốn đọc".';
        typeIcon = Icons.add_circle;
        typeColor = Colors.blue;
        break;
      case 'started_reading':
        description = '$userName bắt đầu đọc "$bookTitle".';
        typeIcon = Icons.menu_book;
        typeColor = const Color(0xFFFA6400);
        break;
      case 'created_note':
        description = '$userName vừa ghi chú một ý tưởng hay${bookTitle.isNotEmpty ? ' từ "$bookTitle"' : ''}.';
        typeIcon = Icons.edit_note;
        typeColor = Colors.orange;
        break;
      default:
        description = '$userName có hoạt động mới.';
        typeIcon = Icons.circle;
        typeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + tên + thời gian
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: typeColor.withOpacity(0.2),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mô tả theo đúng format yêu cầu
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRelativeTime(createdAt),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Hiện ảnh bìa sách nếu có
          if (bookImage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      bookImage,
                      width: 45, height: 65, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 45, height: 65,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        if (bookAuthor.isNotEmpty)
                          Text(bookAuthor, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        if (rating != null)
                          Row(
                            children: List.generate(5, (i) =>
                              Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Hiện nội dung ghi chú nếu có
          if (noteContent != null && noteContent.toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFF9C4)),
              ),
              child: Text(
                '"${noteContent.toString()}"',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${(diff.inDays / 7).floor()} tuần trước';
  }

  void _showFriendsList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> friends) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('Bạn bè (${friends.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (friends.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text('Chưa có bạn bè nào', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              else
                ...friends.map((friendship) {
                  final friend = friendship['friend'] ?? {};
                  final name = friend['name'] ?? 'Người dùng';
                  final email = friend['email'] ?? '';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22, backgroundColor: const Color(0xFFFA6400),
                          child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_remove, color: Colors.red, size: 20),
                          onPressed: () {
                            ref.read(communityControllerProvider.notifier).removeFriend(friendship['id']);
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
