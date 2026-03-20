import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.id;
  }

  /// Tạo hoạt động mới
  Future<void> createActivity({
    required String type,
    String? bookTitle,
    String? bookImageUrl,
    String? bookAuthor,
    int? rating,
    String? noteContent,
    int? notePage,
  }) async {
    try {
      await _client.from('activities').insert({
        'user_id': _userId,
        'type': type,
        'book_title': bookTitle,
        'book_image_url': bookImageUrl,
        'book_author': bookAuthor,
        'rating': rating,
        'note_content': noteContent,
        'note_page': notePage,
      });
      print('[ActivityRepo] Created activity: $type for $bookTitle');
    } catch (e) {
      print('[ActivityRepo] Error creating activity: $e');
    }
  }

  /// Lấy danh sách bạn bè IDs
  Future<List<String>> _getFriendIds() async {
    try {
      final userId = _userId;
      
      final sent = await _client
          .from('friendships')
          .select('friend_id')
          .eq('user_id', userId)
          .eq('status', 'accepted');
      
      final received = await _client
          .from('friendships')
          .select('user_id')
          .eq('friend_id', userId)
          .eq('status', 'accepted');

      final ids = <String>{};
      for (final row in List<Map<String, dynamic>>.from(sent)) {
        ids.add(row['friend_id']);
      }
      for (final row in List<Map<String, dynamic>>.from(received)) {
        ids.add(row['user_id']);
      }
<<<<<<< HEAD
      // Thêm cả bản thân để xem hoạt động của mình
      ids.add(userId);
=======
>>>>>>> feature-library
      
      print('[ActivityRepo] Friend IDs: $ids');
      return ids.toList();
    } catch (e) {
      print('[ActivityRepo] Error getting friend IDs: $e');
      return [_userId];
    }
  }

  /// Lấy thông tin user
  Future<Map<String, dynamic>?> _getUserById(String userId) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      return null;
    }
  }

  /// FR4.2 - Feed hoạt động của Vòng tròn Tin cậy
  Future<List<Map<String, dynamic>>> getFeed() async {
    try {
      final friendIds = await _getFriendIds();
      
      if (friendIds.isEmpty) {
        print('[ActivityRepo] No friends, empty feed');
        return [];
      }

      // Lấy activities từ bạn bè + bản thân
      final data = await _client
          .from('activities')
          .select()
          .inFilter('user_id', friendIds)
          .order('created_at', ascending: false)
          .limit(50);
      
      print('[ActivityRepo] Raw feed count: ${(data as List).length}');

      // Gắn thông tin user vào mỗi activity
      final results = <Map<String, dynamic>>[];
      for (final row in List<Map<String, dynamic>>.from(data)) {
        final userInfo = await _getUserById(row['user_id']);
        if (userInfo != null) {
          row['user'] = userInfo;
          results.add(row);
        }
      }

      print('[ActivityRepo] Final feed count: ${results.length}');
      return results;
    } catch (e) {
      print('[ActivityRepo] Error fetching feed: $e');
      return [];
    }
  }

<<<<<<< HEAD
  /// FR4.3 - Gợi ý cá nhân hóa: sách mà nhiều bạn bè đã đọc
  Future<List<Map<String, dynamic>>> getFriendRecommendations() async {
    try {
      final friendIds = await _getFriendIds();
      friendIds.remove(_userId); // Chỉ lấy bạn bè, bỏ bản thân
      
      if (friendIds.isEmpty) return [];

      // Lấy activities thêm sách / đọc xong từ bạn bè
      final data = await _client
          .from('activities')
          .select()
          .inFilter('user_id', friendIds)
          .inFilter('type', ['added_book', 'finished_book', 'started_reading'])
          .order('created_at', ascending: false);

      // Đếm mỗi cuốn sách có bao nhiêu bạn đọc
      final Map<String, Map<String, dynamic>> bookCounts = {};
      final Map<String, Set<String>> bookReaders = {};

      for (final row in List<Map<String, dynamic>>.from(data)) {
        final title = row['book_title'] ?? '';
        if (title.isEmpty) continue;

        if (!bookCounts.containsKey(title)) {
          bookCounts[title] = {
            'book_title': title,
            'book_author': row['book_author'] ?? '',
            'book_image_url': row['book_image_url'] ?? '',
            'count': 0,
            'reader_names': <String>[],
          };
          bookReaders[title] = {};
        }

        final userId = row['user_id'];
        if (!bookReaders[title]!.contains(userId)) {
          bookReaders[title]!.add(userId);
          bookCounts[title]!['count'] = bookReaders[title]!.length;
        }
      }

      // Lấy tên người đọc
      for (final title in bookCounts.keys) {
        final names = <String>[];
        for (final uid in bookReaders[title]!) {
          final userInfo = await _getUserById(uid);
          if (userInfo != null) {
            names.add(userInfo['name'] ?? 'Ai đó');
          }
        }
        bookCounts[title]!['reader_names'] = names;
      }

      // Sắp xếp theo số người đọc giảm dần
      final sorted = bookCounts.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return sorted.take(5).toList(); // Top 5 gợi ý
    } catch (e) {
      print('[ActivityRepo] Error getting recommendations: $e');
=======
  Future<List<Map<String, dynamic>>> getFriendRecommendations() async {
    try {
      final friendIds = await _getFriendIds();
      friendIds.remove(_userId); // Chỉ lấy bạn bè thực sự, bỏ bản thân
      
      if (friendIds.isEmpty) return [];

      // FR4.3: Lấy trực tiếp danh sách các sách mà bạn bè đang đọc (status = 'Reading')
      final data = await _client
          .from('user_books')
          .select('title, authors, image_url, custom_cover_url, date_added')
          .inFilter('user_id', friendIds)
          .eq('status', 'Reading')
          .order('date_added', ascending: false)
          .limit(10);

      // Đếm mỗi cuốn sách có bao nhiêu bạn đọc để loại bỏ trùng lặp và nhóm lại
      final Map<String, Map<String, dynamic>> uniqueBooks = {};

      for (final row in List<Map<String, dynamic>>.from(data)) {
        final title = row['title'] ?? '';
        if (title.isEmpty || uniqueBooks.containsKey(title)) continue;

        String author = '';
        if (row['authors'] != null && (row['authors'] as List).isNotEmpty) {
           author = row['authors'][0].toString();
        }

        uniqueBooks[title] = {
          'book_title': title,
          'book_author': author,
          'book_image_url': row['custom_cover_url'] ?? row['image_url'] ?? '',
        };
      }

      return uniqueBooks.values.toList();
    } catch (e) {
      print('[ActivityRepo] Error getting reading lists: $e');
>>>>>>> feature-library
      return [];
    }
  }

  /// Like một hoạt động (Ghi nhận vào bảng activity_likes và cập nhật counters)
  Future<void> likeActivity(String activityId) async {
    try {
      final userId = _userId;
      
      // 1. Thêm vào bảng chi tiết (Sử dụng upsert để tránh trùng lặp)
      try {
        await _client.from('activity_likes').upsert({
          'activity_id': activityId,
          'user_id': userId,
        });
      } catch (e) {
        // Có thể bảng chưa tồn tại, ta chỉ tiếp tục cập nhật counter
        print('[ActivityRepo] Detail likes table skip: $e');
      }

      // 2. Cập nhật số lượng tổng ở bảng chính
      final response = await _client
          .from('activities')
          .select('likes')
          .eq('id', activityId)
          .single();
      final currentLikes = response['likes'] ?? 0;
      await _client
          .from('activities')
          .update({'likes': currentLikes + 1})
          .eq('id', activityId);
    } catch (e) {
      print('[ActivityRepo] Error liking activity: $e');
      rethrow;
    }
  }

  /// Bình luận vào một hoạt động (Lưu vào activity_comments và cập nhật counters)
  Future<void> commentOnActivity(String activityId, String content) async {
    try {
      final userId = _userId;

      // 1. Lưu bình luận chi tiết
      try {
        await _client.from('activity_comments').insert({
          'activity_id': activityId,
          'user_id': userId,
          'content': content,
        });
      } catch (e) {
        print('[ActivityRepo] Detail comments table skip: $e');
      }

      // 2. Cập nhật counter
      final response = await _client
          .from('activities')
          .select('comments')
          .eq('id', activityId)
          .single();
      final currentComments = response['comments'] ?? 0;
      await _client
          .from('activities')
          .update({'comments': currentComments + 1})
          .eq('id', activityId);
    } catch (e) {
      print('[ActivityRepo] Error commenting on activity: $e');
      rethrow;
    }
  }
}
