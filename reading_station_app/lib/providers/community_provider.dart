import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/friendship_repository.dart';
import '../repositories/activity_repository.dart';

final friendshipRepositoryProvider = Provider<FriendshipRepository>((ref) {
  return FriendshipRepository();
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

/// Danh sách bạn bè
final friendsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(friendshipRepositoryProvider).getFriends();
});

/// Lời mời đang chờ
final pendingRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(friendshipRepositoryProvider).getPendingRequests();
});

/// Feed hoạt động
final feedProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(activityRepositoryProvider).getFeed();
});

/// FR4.3 - Gợi ý cá nhân hóa từ bạn bè
final friendRecommendationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(activityRepositoryProvider).getFriendRecommendations();
});

/// Gợi ý kết bạn (người dùng mới/ngẫu nhiên chưa kết bạn)
final suggestedFriendsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(friendshipRepositoryProvider).getSuggestedFriends();
});

/// Kết quả search user
final searchUsersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return ref.watch(friendshipRepositoryProvider).searchUsers(query);
});

/// Mảng tạm lưu các ID đã ấn Gửi yêu cầu để đổi hiển thị ngay lập tức
class LocalSentRequestsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void add(String id) {
    state = <String>{...state, id};
  }

  void remove(String id) {
    final newSet = <String>{...state};
    newSet.remove(id);
    state = newSet;
  }
}

final localSentRequestsProvider = NotifierProvider<LocalSentRequestsNotifier, Set<String>>(LocalSentRequestsNotifier.new);

class CommunityController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> sendFriendRequest(String friendId) async {
    state = const AsyncLoading();
    try {
      await ref.read(friendshipRepositoryProvider).sendFriendRequest(friendId);
      ref.invalidate(friendsProvider);
      ref.invalidate(pendingRequestsProvider);
      // ref.invalidate(suggestedFriendsProvider); // Không invalidate để không làm mất item đang hiển thị
      
      // Đánh dấu là đã gửi thành công trong thiết bị
      ref.read(localSentRequestsProvider.notifier).add(friendId);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> cancelFriendRequestInSuggestion(String friendId) async {
    state = const AsyncLoading();
    try {
      await ref.read(friendshipRepositoryProvider).cancelRequest(friendId);
      ref.invalidate(pendingRequestsProvider);
      
      // Xóa dấu vết gửi thành công
      ref.read(localSentRequestsProvider.notifier).remove(friendId);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> acceptRequest(String friendshipId) async {
    try {
      await ref.read(friendshipRepositoryProvider).acceptFriendRequest(friendshipId);
      ref.invalidate(friendsProvider);
      ref.invalidate(pendingRequestsProvider);
      ref.invalidate(feedProvider);
      ref.invalidate(suggestedFriendsProvider);
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  Future<void> likeActivity(String activityId) async {
    try {
      await ref.read(activityRepositoryProvider).likeActivity(activityId);
      ref.invalidate(feedProvider);
    } catch (e) {
      print('Error liking activity: $e');
    }
  }

  Future<void> commentOnActivity(String activityId, String content, {String? parentId}) async {
    try {
      await ref.read(activityRepositoryProvider).commentOnActivity(activityId, content, parentId: parentId);
      ref.invalidate(feedProvider);
    } catch (e) {
      print('Error commenting: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getComments(String activityId) async {
    return await ref.read(activityRepositoryProvider).getComments(activityId);
  }

  Future<void> removeFriend(String friendshipId) async {
    try {
      await ref.read(friendshipRepositoryProvider).removeFriendship(friendshipId);
      ref.invalidate(friendsProvider);
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  /// Tạo activity khi user thực hiện hành động
  Future<void> postActivity({
    required String type,
    String? bookTitle,
    String? bookImageUrl,
    String? bookAuthor,
    int? rating,
    String? noteContent,
    int? notePage,
  }) async {
    try {
      await ref.read(activityRepositoryProvider).createActivity(
        type: type,
        bookTitle: bookTitle,
        bookImageUrl: bookImageUrl,
        bookAuthor: bookAuthor,
        rating: rating,
        noteContent: noteContent,
        notePage: notePage,
      );
      ref.invalidate(feedProvider);
    } catch (e) {
      print('Error posting activity: $e');
    }
  }
}

final communityControllerProvider =
    AsyncNotifierProvider<CommunityController, void>(CommunityController.new);
