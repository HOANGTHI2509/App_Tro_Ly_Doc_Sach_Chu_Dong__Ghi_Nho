import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/community_provider.dart';
import 'add_friend_screen.dart';
import 'friends_management_screen.dart';
import 'pending_requests_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'comments_bottom_sheet.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  final Color _primaryGreen = const Color(0xFF4A745B);
  final Color _bgBeige = const Color(0xFFF9F7F2);
  final Color _cardBg = const Color(0xFFF2EFE9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);

    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: AppBar(
        backgroundColor: _bgBeige,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: _primaryGreen),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Vòng tròn Tin cậy',
          style: TextStyle(color: Color(0xFF385A46), fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Serif'),
        ),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final pendingAsync = ref.watch(pendingRequestsProvider);
              final count = pendingAsync.asData?.value.length ?? 0;

              return IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingRequestsScreen())),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined, color: Color(0xFF385A46), size: 28),
                    if (count > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text(
                            '$count',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final user = Supabase.instance.client.auth.currentUser;
              final userName = user?.userMetadata?['name'] ?? 'User';
              final avatarUrl = user?.userMetadata?['avatar_url'];

              return Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFF5B08C),
                  radius: 18,
                  backgroundImage: avatarUrl != null 
                      ? NetworkImage(avatarUrl) 
                      : NetworkImage('https://ui-avatars.com/api/?name=$userName&background=random'),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(friendsProvider);
          ref.invalidate(pendingRequestsProvider);
          ref.invalidate(feedProvider);
          ref.invalidate(suggestedFriendsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildSearchBar(context),
              const SizedBox(height: 24),

              friendsAsync.when(
                data: (friends) {
                  if (friends.isEmpty) {
                    return _buildIntroUI(context);
                  }
                  return _buildActiveUI(context, ref, friends);
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
                error: (_, __) => _buildIntroUI(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFriendScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EDE4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFFBDBDBD)),
            const SizedBox(width: 10),
            const Text(
              'Tìm kiếm bạn bè...',
              style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroUI(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text('Kết nối cộng đồng\ntin cậy', textAlign: TextAlign.center, style: TextStyle(color: _primaryGreen, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 16),
              const Text('Tham gia vào vòng tròn tin cậy để khám phá những cuốn sách bạn bè đang đọc và chia sẻ những cảm nhận chân thực nhất.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF616161), fontSize: 14, height: 1.5)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFriendScreen())),
                icon: const Icon(Icons.person_add, color: Color(0xFFFFFFFF), size: 20),
                label: const Text('Tìm kiếm bạn bè', style: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildInfoCard(icon: Icons.shield_outlined, title: 'Quyền riêng tư', desc: 'Chỉ những người bạn tin cậy mới có thể thấy tủ sách cá nhân của bạn.'),
        const SizedBox(height: 16),
        _buildInfoCard(icon: Icons.menu_book_outlined, title: 'Cùng nhau đọc', desc: 'Tạo nhóm đọc chung và thảo luận về các tác phẩm yêu thích.'),
      ],
    );
  }

  Widget _buildActiveUI(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> friends) {
    final feedAsync = ref.watch(feedProvider);
    final recommendAsync = ref.watch(friendRecommendationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.people, color: Color(0xFF385A46), size: 22),
                SizedBox(width: 8),
                Text('Danh sách bạn bè', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF385A46), fontFamily: 'Serif')),
              ],
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsManagementScreen())),
              icon: const Icon(Icons.settings_outlined, size: 16, color: Color(0xFF5D4037)),
              label: const Text('Quản lý', style: TextStyle(color: Color(0xFF5D4037), fontSize: 13, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(backgroundColor: const Color(0xFFEBE3D5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BẠN BÈ ĐANG ĐỌC GÌ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF9E9E9E), letterSpacing: 1.0)),
              const SizedBox(height: 16),
              recommendAsync.when(
                data: (recs) {
                  if (recs.isEmpty) return const Text('Bạn bè hiện chưa đọc cuốn sách nào mới.', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)));
                  return SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recs.length,
                      itemBuilder: (ctx, i) {
                        final rec = recs[i];
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(rec['book_image_url'] ?? '', height: 100, width: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFEEEEEE), height: 100, child: const Icon(Icons.book, size: 30))),
                              ),
                              const SizedBox(height: 8),
                              Text(rec['book_title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FriendsManagementScreen())),
                  icon: Icon(Icons.chevron_right, size: 16, color: _primaryGreen.withOpacity(0.8)),
                  label: Text('XEM TẤT CẢ BẠN BÈ', style: TextStyle(color: _primaryGreen.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  style: TextButton.styleFrom(
                    backgroundColor: _primaryGreen.withOpacity(0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF385A46), size: 22),
            SizedBox(width: 8),
            Text('Hoạt động mới nhất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF385A46), fontFamily: 'Serif')),
          ],
        ),
        const SizedBox(height: 16),

        feedAsync.when(
          data: (activities) {
            if (activities.isEmpty) return const Center(child: Text('Chưa có hoạt động nào từ bạn bè.'));
            return Column(
              children: activities.map((activity) => _buildModernActivityCard(context, ref, activity)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Lỗi tải feed'),
        ),
      ],
    );
  }

  Widget _buildModernActivityCard(BuildContext context, WidgetRef ref, Map<String, dynamic> activity) {
    final user = activity['user'] ?? {};
    final userName = user['name'] ?? 'Ai đó';
    final type = activity['type'] ?? '';
    final bookTitle = activity['book_title'] ?? '';
    final bookAuthor = activity['book_author'] ?? '';
    final bookImage = activity['book_image_url'] ?? '';
    final rating = activity['rating'];
    final noteContent = activity['note_content'];
    final createdAt = DateTime.tryParse(activity['created_at'] ?? '') ?? DateTime.now();

    String actionText = '';
    Widget contentWidget;

    if (type == 'created_note') {
      actionText = 'vừa ghi chú';
      contentWidget = Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFF7F8F6), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote, color: const Color(0xFFD4DAD0), size: 30),
            Text('"$noteContent"', style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Color(0xFF2C3E35), height: 1.5, fontFamily: 'Serif')),
            if (bookTitle.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 16), child: Text('— TỪ ${bookTitle.toUpperCase()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4A745B), letterSpacing: 1.0))),
          ],
        ),
      );
    } else if (type == 'finished_book') {
      actionText = 'vừa đọc xong';
      contentWidget = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFFCF9F2), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(bookImage, width: 60, height: 90, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 40)))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E35), fontFamily: 'Serif')),
                  Text(bookAuthor.isNotEmpty ? bookAuthor : 'Không rõ', style: const TextStyle(color: Color(0xFF757575), fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(children: [
                    ...List.generate(5, (i) => Icon(Icons.star, color: const Color(0xFF795548), size: 14)),
                    const SizedBox(width: 8),
                    Text('${(rating ?? 5).toDouble()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      actionText = 'vừa thêm vào kệ';
      contentWidget = Row(
        children: [
          Container(decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(bookImage, width: 60, height: 90, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 40)))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFEBE3D5), borderRadius: BorderRadius.circular(8)), child: const Text('MUỐN ĐỌC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5D4037), letterSpacing: 1.0))),
                const SizedBox(height: 8),
                Text(bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E35), fontFamily: 'Serif')),
                Text(bookAuthor, style: const TextStyle(color: Color(0xFF757575), fontSize: 13)),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(radius: 20, backgroundColor: _primaryGreen.withOpacity(0.1), backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${userName}&background=random')),
                  Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle, color: Color(0xFF4A745B), size: 14),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text.rich(TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C3E35)), children: [TextSpan(text: ' $actionText', style: const TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF757575)))])),
                  Text(_getRelativeTime(createdAt).toUpperCase(), style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E), letterSpacing: 1.0, fontWeight: FontWeight.bold)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          contentWidget,
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInteractionButton(
                icon: (activity['is_liked'] == true) ? Icons.favorite : Icons.favorite_border,
                iconColor: (activity['is_liked'] == true) ? Colors.red : Colors.grey[600],
                label: '${activity['likes'] ?? 0}', 
                onTap: () => ref.read(communityControllerProvider.notifier).likeActivity(activity['id']),
              ),
              const SizedBox(width: 24),
              _buildInteractionButton(
                icon: Icons.chat_bubble_outline, 
                label: '${activity['comments'] ?? 0}', 
                onTap: () => _showCommentsSheet(context, activity['id']),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({required IconData icon, Color? iconColor, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, String activityId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: CommentsBottomSheet(activityId: activityId),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8B7355), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Color(0xFF757575), fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) return '${duration.inMinutes} phút trước';
    if (duration.inHours < 24) return '${duration.inHours} giờ trước';
    return '${duration.inDays} ngày trước';
  }
}

