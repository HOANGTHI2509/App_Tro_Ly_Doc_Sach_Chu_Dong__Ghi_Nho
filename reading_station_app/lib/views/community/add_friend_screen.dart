import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/community_provider.dart';

class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  final Set<String> _sentRequests = {};

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final repo = ref.read(friendshipRepositoryProvider);
      final results = await repo.searchUsers(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000000)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm vào Vòng tròn',
          style: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              onChanged: (val) {
                if (val.length >= 3) _search();
              },
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF5722)),
                  onPressed: _search,
                ),
                filled: true,
                fillColor: const Color(0xFFFFEBE5).withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            if (_isSearching)
              const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
            else if (_searchResults.isNotEmpty) ...[
              Text(
                'Kết quả (${_searchResults.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 15),
              ..._searchResults.map((user) {
                final userId = user['id'];
                final isSent = _sentRequests.contains(userId);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFFA6400),
                        child: Text(
                          (user['name'] ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['name'] ?? 'Người dùng', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(user['email'] ?? '', style: const TextStyle(color: Color(0xFF757575), fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isSent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Đã gửi', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      else
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await ref.read(communityControllerProvider.notifier).sendFriendRequest(userId);
                              setState(() => _sentRequests.add(userId));
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Đã gửi lời mời kết bạn!'),
                                    backgroundColor: Color(0xFF4CAF50),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e'), backgroundColor: const Color(0xFFF44336)),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5722),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            minimumSize: const Size(80, 32),
                            elevation: 0,
                          ),
                          child: const Text('Kết bạn', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                );
              }),
            ] else if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 40),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.person_search, size: 64, color: Color(0xFFE0E0E0)),
                    SizedBox(height: 16),
                    Text('Không tìm thấy người dùng', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Thử tìm với email hoặc tên khác', style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14)),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 40),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.group_add, size: 64, color: Color(0xFFE0E0E0)),
                    SizedBox(height: 16),
                    Text('Tìm bạn bè', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Nhập tên hoặc email để tìm kiếm', style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
