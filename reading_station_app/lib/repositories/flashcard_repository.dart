import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/flashcard.dart';

class FlashcardRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.id;
  }

  /// Lấy tất cả flashcards
  Future<List<Flashcard>> getAllFlashcards() async {
    try {
      final data = await _client
          .from('flashcards')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);
      return (data as List).map((row) => Flashcard.fromSupabase(row)).toList();
    } catch (e) {
      print('Error fetching flashcards: $e');
      return [];
    }
  }

  /// Lấy flashcards cần ôn hôm nay (next_review_date <= now)
  Future<List<Flashcard>> getDueFlashcards() async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final data = await _client
          .from('flashcards')
          .select()
          .eq('user_id', _userId)
          .lte('next_review_date', now)
          .order('next_review_date', ascending: true);
      return (data as List).map((row) => Flashcard.fromSupabase(row)).toList();
    } catch (e) {
      print('Error fetching due flashcards: $e');
      return [];
    }
  }

  /// Thêm flashcard mới
  Future<void> addFlashcard(Flashcard flashcard) async {
    try {
      await _client.from('flashcards').insert(flashcard.toSupabase());
    } catch (e) {
      print('Error adding flashcard: $e');
      rethrow;
    }
  }

  /// Cập nhật flashcard sau khi ôn tập (SM-2)
  Future<void> updateFlashcard(Flashcard flashcard) async {
    try {
      await _client.from('flashcards').update({
        'ease_factor': flashcard.easeFactor,
        'interval_days': flashcard.intervalDays,
        'repetitions': flashcard.repetitions,
        'next_review_date': flashcard.nextReviewDate.toIso8601String(),
        'last_reviewed_at': flashcard.lastReviewedAt?.toIso8601String(),
      }).eq('id', flashcard.id);
    } catch (e) {
      print('Error updating flashcard: $e');
      rethrow;
    }
  }

  /// Xóa flashcard
  Future<void> deleteFlashcard(String id) async {
    try {
      await _client.from('flashcards').delete().eq('id', id);
    } catch (e) {
      print('Error deleting flashcard: $e');
      rethrow;
    }
  }

  /// Đếm số flashcard đã thuộc (interval >= 21 ngày)
  Future<int> getMasteredCount() async {
    try {
      final data = await _client
          .from('flashcards')
          .select('id')
          .eq('user_id', _userId)
          .gte('interval_days', 21);
      return (data as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Đếm tổng flashcard
  Future<int> getTotalCount() async {
    try {
      final data = await _client
          .from('flashcards')
          .select('id')
          .eq('user_id', _userId);
      return (data as List).length;
    } catch (e) {
      return 0;
    }
  }
}
