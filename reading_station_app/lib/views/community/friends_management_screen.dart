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
          icon: Icon(Icons.menu, color: _primaryGreen),
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

            // Top Stats Cards
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 160,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _primaryGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cộng đồng đọc\nsách của bạn',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Spacer(),
                        Text(
                          '128 người bạn đang trực tuyến',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 160,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _goldBeige,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${pendingAsync.asData?.value.length ?? 0}',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 32),
                        ),
                        const Text(
                          'YÊU CẦU\nMỚI',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            // Pending Requests Section
            _buildPendingRequestsSection(context, ref),
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
                  children: friends.map((f) => _buildFriendCard(f)).toList(),
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

  Widget _buildFriendCard(Map<String, dynamic> friendship) {
    final friend = friendship['friend'] ?? {};
    final name = friend['name'] ?? 'Người dùng';
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
          Icon(Icons.person_remove_outlined, color: Colors.grey[400]),
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
        color: const Color(0xFFF3F1ED),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gợi ý bạn bè',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          suggestedAsync.when(
            data: (users) {
              if (users.isEmpty) return const Text('Hiện chưa có gợi ý mới.', style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)));
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: users.map((u) => Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: _buildSuggestionItem(context, ref, u),
                  )).toList(),
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

  Widget _buildPendingRequestsSection(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRequestsProvider);

    return pendingAsync.when(
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lời mời kết bạn',
              style: TextStyle(color: _primaryGreen.withOpacity(0.8), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...requests.map((r) => _buildPendingRequestCard(context, ref, r)),
            const SizedBox(height: 32),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPendingRequestCard(BuildContext context, WidgetRef ref, Map<String, dynamic> request) {
    final sender = request['friend'] ?? {};
    final name = sender['name'] ?? 'Người dùng';
    final friendshipId = request['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _goldBeige.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
             radius: 25,
             backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$name&background=random'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(communityControllerProvider.notifier).acceptRequest(friendshipId);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã chấp nhận lời mời của $name')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(80, 32),
            ),
            child: const Text('Chấp nhận', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
  Widget _buildSuggestionItem(BuildContext context, WidgetRef ref, Map<String, dynamic> user) {
    final name = user['name'] ?? 'Người dùng';
    final userId = user['id'];

    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: _primaryGreen.withOpacity(0.1),
          backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$name&background=random'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 70,
          child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            ref.read(communityControllerProvider.notifier).sendFriendRequest(userId);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã gửi lời mời tới $name')));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            minimumSize: const Size(60, 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text('Thêm', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 11)),
        ),
      ],
    );
  }
}
