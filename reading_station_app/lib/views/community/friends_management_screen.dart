import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/community_provider.dart';

class FriendsManagementScreen extends ConsumerWidget {
  const FriendsManagementScreen({super.key});

  final Color _primaryGreen = const Color(0xFF79A385);
  final Color _goldBeige = const Color(0xFFC4AA72);
  final Color _bgBeige = const Color(0xFFF9F7F2);
  final Color _cardBg = const Color(0xFFF2EFE9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);
    final pendingAsync = ref.watch(pendingRequestsProvider);

    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: AppBar(
        backgroundColor: _bgBeige,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bạn bè',
          style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: _primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EDE6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Tìm kiếm bạn bè...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

                Container(
                  height: 160,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _primaryGreen,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cộng đồng đọc\nsách của bạn',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Spacer(),
                      Text(
                        '${friendsAsync.asData?.value.length ?? 0} người bạn đang trực tuyến',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

            const SizedBox(height: 32),

            Text(
              'Danh sách bạn bè',
              style: TextStyle(color: _primaryGreen.withOpacity(0.8), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Friends List
            friendsAsync.when(
              data: (friends) {
                if (friends.isEmpty) return const Text('Bạn chưa có người bạn nào.');
                return Column(
                  children: friends.map((f) => _buildFriendCard(context, ref, f)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Lỗi tải danh sách bạn bè'),
            ),

            const SizedBox(height: 32),

            // Suggestions Section
            _buildSuggestionsSection(context, ref),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, WidgetRef ref, Map<String, dynamic> friendship) {
    final friend = friendship['friend'] ?? {};
    final name = friend['name'] ?? 'Người dùng';
    final friendshipId = friendship['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$name&background=random'),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.menu_book, size: 14, color: Color(0xFF8B7355)),
                    const SizedBox(width: 6),
                    Text(
                      'Đang đọc sách hay', // Placeholder status
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.person_remove_outlined, color: Colors.grey[400]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFFF9F7F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text(
                    'Xóa kết bạn', 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Serif', fontWeight: FontWeight.bold, color: Color(0xFF79A385), fontSize: 22)
                  ),
                  content: Text(
                    'Bạn có chắc chắn muốn hủy kết bạn với $name không?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF616161), fontSize: 15, height: 1.4)
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actionsPadding: const EdgeInsets.only(bottom: 24, top: 12),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => Navigator.pop(ctx), 
                      child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16))
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        ref.read(communityControllerProvider.notifier).removeFriend(friendshipId);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã hủy kết bạn với $name')));
                      },
                      child: const Text('Chắc chắn xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context, WidgetRef ref) {
    final suggestedAsync = ref.watch(suggestedFriendsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EA), // Match the beige background from the design
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gợi ý bạn bè',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5D5144), fontFamily: 'Serif'),
          ),
          const SizedBox(height: 24),
          suggestedAsync.when(
            data: (users) {
              if (users.isEmpty) return const Text('Hiện chưa có gợi ý mới.', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)));
              return SizedBox(
                height: 160, // Increased height to prevent overflow
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: _buildSuggestionItem(context, ref, users[index]),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Lỗi tải gợi ý'),
          ),
        ],
      ),
    );
  }


  Widget _buildSuggestionItem(BuildContext context, WidgetRef ref, Map<String, dynamic> user) {
    final name = user['name'] ?? 'Người dùng';
    final userId = user['id'];
    
    final localSentSet = ref.watch(localSentRequestsProvider);
    final isSent = localSentSet.contains(userId);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF79A385), width: 2), // Green border
            color: Colors.white,
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF79A385).withOpacity(0.1),
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$name&background=random'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 80,
          child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 76, // Makes the button match the image perfectly
          height: 28,
          child: ElevatedButton(
            onPressed: () {
              if (isSent) {
                ref.read(communityControllerProvider.notifier).cancelFriendRequestInSuggestion(userId);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã hủy yêu cầu tới $name')));
              } else {
                ref.read(communityControllerProvider.notifier).sendFriendRequest(userId);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã gửi lời mời tới $name')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSent ? const Color(0xFFE0E0E0) : const Color(0xFF4F7E60),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(isSent ? 'Đã gửi' : 'Thêm', style: TextStyle(color: isSent ? const Color(0xFF9E9E9E) : Colors.white, fontSize: 12, fontWeight: isSent ? FontWeight.bold : FontWeight.normal)),
          ),
        ),
      ],
    );
  }
}
