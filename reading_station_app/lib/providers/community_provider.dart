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

/// Kết quả search user
final searchUsersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return ref.watch(friendshipRepositoryProvider).searchUsers(query);
});

class CommunityController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> sendFriendRequest(String friendId) async {
    state = const AsyncLoading();
    try {
      await ref.read(friendshipRepositoryProvider).sendFriendRequest(friendId);
      ref.invalidate(friendsProvider);
      ref.invalidate(pendingRequestsProvider);
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
    } catch (e) {
      print('Error accepting request: $e');
    }
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
