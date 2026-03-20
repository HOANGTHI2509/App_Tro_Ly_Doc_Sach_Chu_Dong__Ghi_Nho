import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/community_provider.dart';

class PendingRequestsScreen extends ConsumerWidget {
  const PendingRequestsScreen({super.key});

  final Color _primaryGreen = const Color(0xFF79A385);
  final Color _bgBeige = const Color(0xFFF9F7F2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Thông báo',
          style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: pendingAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'Bạn không có lời mời kết bạn mới nào.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final sender = request['friend'] ?? {};
              final name = sender['name'] ?? 'Người dùng';
              final friendshipId = request['id'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=$name&background=random'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text('Đã gửi lời mời kết bạn', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(communityControllerProvider.notifier).acceptRequest(friendshipId);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã chấp nhận lời mời của $name')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text('Đồng ý', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Lỗi tải thông báo')),
      ),
    );
  }
}
