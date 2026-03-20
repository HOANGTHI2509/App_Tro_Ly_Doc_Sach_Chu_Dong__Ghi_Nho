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

      // Lấy danh sách activity id mà user hiện tại đã like
      final myLikesResp = await _client.from('activity_likes').select('activity_id').eq('user_id', _userId).catchError((_) => []);
      final myLikedActivities = (myLikesResp as List).map((e) => e['activity_id']).toSet();

      // Đếm lượt like thời gian thực
      final activityIds = data.map((e) => e['id']).toList();
      final allLikesResp = await _client.from('activity_likes').select('activity_id').inFilter('activity_id', activityIds).catchError((_) => []);
      final Map<String, int> likesCountMap = {};
      for (final row in (allLikesResp as List)) {
        final aid = row['activity_id'].toString();
        likesCountMap[aid] = (likesCountMap[aid] ?? 0) + 1;
      }

      // Đếm lượt cmt thời gian thực
      final allCmtsResp = await _client.from('activity_comments').select('activity_id').inFilter('activity_id', activityIds).catchError((_) => []);
      final Map<String, int> cmtsCountMap = {};
      for (final row in (allCmtsResp as List)) {
        final aid = row['activity_id'].toString();
        cmtsCountMap[aid] = (cmtsCountMap[aid] ?? 0) + 1;
      }

      // Gắn thông tin user vào mỗi activity
      final results = <Map<String, dynamic>>[];
      for (final row in List<Map<String, dynamic>>.from(data)) {
        final userInfo = await _getUserById(row['user_id']);
        if (userInfo != null) {
          row['user'] = userInfo;
          row['is_liked'] = myLikedActivities.contains(row['id']);
          // Override counter hiển thị
          row['likes'] = likesCountMap[row['id'].toString()] ?? 0;
          row['comments'] = cmtsCountMap[row['id'].toString()] ?? 0;
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
      return [];
    }
  }

  /// Like / Unlike một hoạt động
  Future<void> likeActivity(String activityId) async {
    try {
      final userId = _userId;
      
      // Kiểm tra xem đã like chưa
      final existingLike = await _client
          .from('activity_likes')
          .select()
          .eq('activity_id', activityId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        // Đã like rồi -> unlike
        await _client
            .from('activity_likes')
            .delete()
            .eq('activity_id', activityId)
            .eq('user_id', userId);
            
        // Trừ counter
        try {
          final response = await _client.from('activities').select('likes').eq('id', activityId).single();
          final currentLikes = response['likes'] ?? 0;
          if (currentLikes > 0) {
            await _client.from('activities').update({'likes': currentLikes - 1}).eq('id', activityId);
          }
        } catch (_) {}
      } else {
        // Chưa like -> like
        await _client.from('activity_likes').insert({
          'activity_id': activityId,
          'user_id': userId,
        });

        // Cộng counter
        try {
          final response = await _client.from('activities').select('likes').eq('id', activityId).single();
          final currentLikes = response['likes'] ?? 0;
          await _client.from('activities').update({'likes': currentLikes + 1}).eq('id', activityId);
        } catch (_) {}
      }
    } catch (e) {
      print('[ActivityRepo] Error liking activity: $e');
      rethrow;
    }
  }

  /// Lấy danh sách bình luận
  Future<List<Map<String, dynamic>>> getComments(String activityId) async {
    try {
      final data = await _client
          .from('activity_comments')
          .select()
          .eq('activity_id', activityId)
          .order('created_at', ascending: true);
          
      final results = <Map<String, dynamic>>[];
      for (final row in List<Map<String, dynamic>>.from(data)) {
        final userInfo = await _getUserById(row['user_id']);
        if (userInfo != null) {
          row['user'] = userInfo;
        }
        results.add(row);
      }
      return results;
    } catch (e) {
      print('[ActivityRepo] Error fetching comments: $e');
      return [];
    }
  }

  /// Bình luận vào một hoạt động
  Future<void> commentOnActivity(String activityId, String content, {String? parentId}) async {
    try {
      final userId = _userId;

      Map<String, dynamic> insertData = {
        'activity_id': activityId,
        'user_id': userId,
        'content': content,
      };
      if (parentId != null) {
        insertData['parent_id'] = parentId;
      }

      // 1. Lưu bình luận chi tiết
      try {
        await _client.from('activity_comments').insert(insertData);
      } catch (e) {
        // Fallback for when parent_id column does not exist
        if (e.toString().contains('parent_id')) {
           insertData.remove('parent_id');
           await _client.from('activity_comments').insert(insertData);
        } else {
           print('[ActivityRepo] Detail comments table error: $e');
        }
      }

      // 2. Cập nhật counter
      try {
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
      } catch (_) {}
    } catch (e) {
      print('[ActivityRepo] Error commenting on activity: $e');
      rethrow;
    }
  }
}
