import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/flashcard.dart';
import '../repositories/flashcard_repository.dart';

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  return FlashcardRepository();
});

/// Flashcards cần ôn hôm nay
final dueFlashcardsProvider = FutureProvider<List<Flashcard>>((ref) async {
  return ref.watch(flashcardRepositoryProvider).getDueFlashcards();
});

/// Tất cả flashcards
final allFlashcardsProvider = FutureProvider<List<Flashcard>>((ref) async {
  return ref.watch(flashcardRepositoryProvider).getAllFlashcards();
});

/// Thống kê
final flashcardStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(flashcardRepositoryProvider);
  final mastered = await repo.getMasteredCount();
  final total = await repo.getTotalCount();
  final due = await repo.getDueFlashcards();
  return {
    'mastered': mastered,
    'total': total,
    'due': due.length,
  };
});

class FlashcardController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Tạo flashcard từ ghi chú
  Future<void> createFromNote({
    required String noteId,
    required String front,
    required String back,
  }) async {
    state = const AsyncLoading();
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final flashcard = Flashcard(
        id: const Uuid().v4(),
        noteId: noteId,
        userId: userId,
        front: front,
        back: back,
        nextReviewDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await ref.read(flashcardRepositoryProvider).addFlashcard(flashcard);
      ref.invalidate(dueFlashcardsProvider);
      ref.invalidate(allFlashcardsProvider);
      ref.invalidate(flashcardStatsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Ôn tập flashcard với chất lượng (0-5)
  Future<void> reviewFlashcard(Flashcard flashcard, int quality) async {
    try {
      final updated = flashcard.reviewedWith(quality);
      await ref.read(flashcardRepositoryProvider).updateFlashcard(updated);
      ref.invalidate(dueFlashcardsProvider);
      ref.invalidate(flashcardStatsProvider);
    } catch (e) {
      print('Error reviewing flashcard: $e');
    }
  }

  /// Xóa flashcard
  Future<void> deleteFlashcard(String id) async {
    try {
      await ref.read(flashcardRepositoryProvider).deleteFlashcard(id);
      ref.invalidate(dueFlashcardsProvider);
      ref.invalidate(allFlashcardsProvider);
      ref.invalidate(flashcardStatsProvider);
    } catch (e) {
      print('Error deleting flashcard: $e');
    }
  }
}

final flashcardControllerProvider =
    AsyncNotifierProvider<FlashcardController, void>(FlashcardController.new);
