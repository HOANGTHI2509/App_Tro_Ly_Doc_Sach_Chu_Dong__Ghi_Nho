import 'package:supabase_flutter/supabase_flutter.dart';

class FriendshipRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.id;
  }

  /// Tìm người dùng theo email hoặc tên
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .or('email.ilike.%$query%,name.ilike.%$query%')
          .neq('id', _userId)
          .limit(20);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Gửi lời mời kết bạn
  Future<void> sendFriendRequest(String friendId) async {
    try {
      await _client.from('friendships').insert({
        'user_id': _userId,
        'friend_id': friendId,
        'status': 'pending',
      });
    } catch (e) {
      print('Error sending friend request: $e');
      rethrow;
    }
  }

  /// Chấp nhận lời mời
  Future<void> acceptFriendRequest(String friendshipId) async {
    try {
      await _client
          .from('friendships')
          .update({'status': 'accepted'})
          .eq('id', friendshipId);
    } catch (e) {
      print('Error accepting friend request: $e');
      rethrow;
    }
  }

  /// Từ chối / Hủy kết bạn
  Future<void> removeFriendship(String friendshipId) async {
    try {
      await _client.from('friendships').delete().eq('id', friendshipId);
    } catch (e) {
      print('Error removing friendship: $e');
      rethrow;
    }
  }

  /// Helper: lấy thông tin user theo ID
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

  /// Lấy danh sách bạn bè (đã accepted)
  Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final userId = _userId;
      
      // Lấy tất cả friendships đã accepted
      final sent = await _client
          .from('friendships')
          .select()
          .eq('user_id', userId)
          .eq('status', 'accepted');

      final received = await _client
          .from('friendships')
          .select()
          .eq('friend_id', userId)
          .eq('status', 'accepted');

      final results = <Map<String, dynamic>>[];

      // Với mỗi friendship, lấy info của người kia
      for (final row in List<Map<String, dynamic>>.from(sent)) {
        final friendInfo = await _getUserById(row['friend_id']);
        if (friendInfo != null) {
          row['friend'] = friendInfo;
          results.add(row);
        }
      }
      for (final row in List<Map<String, dynamic>>.from(received)) {
        final friendInfo = await _getUserById(row['user_id']);
        if (friendInfo != null) {
          row['friend'] = friendInfo;
          results.add(row);
        }
      }

      return results;
    } catch (e) {
      print('Error getting friends: $e');
      return [];
    }
  }

  /// Lấy lời mời đang chờ (người khác gửi cho tôi)
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    try {
      final userId = _userId;
      print('[FriendshipRepo] Getting pending requests for user: $userId');
      
      final data = await _client
          .from('friendships')
          .select()
          .eq('friend_id', userId)
          .eq('status', 'pending');

      print('[FriendshipRepo] Pending raw data: $data');
      print('[FriendshipRepo] Pending count: ${(data as List).length}');

      final results = <Map<String, dynamic>>[];
      for (final row in List<Map<String, dynamic>>.from(data)) {
        final senderId = row['user_id'];
        print('[FriendshipRepo] Looking up sender: $senderId');
        final senderInfo = await _getUserById(senderId);
        print('[FriendshipRepo] Sender info: $senderInfo');
        if (senderInfo != null) {
          row['friend'] = senderInfo;
          results.add(row);
        }
      }

      print('[FriendshipRepo] Final pending results: ${results.length}');
      return results;
    } catch (e) {
      print('[FriendshipRepo] ERROR getting pending requests: $e');
      return [];
    }
  }
}
