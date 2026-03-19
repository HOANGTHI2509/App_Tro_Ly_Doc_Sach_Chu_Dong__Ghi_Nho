import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class ReviewRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.id;
  }

  /// Fetch all notes that are due for review today or earlier.
  /// Also includes new notes that haven't been reviewed yet (nextReview is null).
  Future<List<Note>> getDueNotes() async {
    final userId = _userId;
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      
      // Fetch notes where next_review <= now OR next_review is null
      // AND is_key_takeaway is true
      final response = await _client
          .from('notes')
          .select('*, user_books!inner(title, image_url, authors)')
          .eq('user_books.user_id', userId)
          .eq('is_key_takeaway', true)
          .or('next_review.lte.$now,next_review.is.null')
          .order('next_review', ascending: true);
      
      return (response as List).map((row) => Note.fromSupabase(row)).toList();
    } catch (e) {
      print('Error fetching due notes: $e');
      return [];
    }
  }

  /// Fetch total notes count for stats
  Future<int> getTotalNotesCount() async {
    final userId = _userId;
    try {
      final response = await _client
          .from('notes')
          .select('id, user_books!inner(user_id)')
          .eq('user_books.user_id', userId)
          .eq('is_key_takeaway', true);
      
      return (response as List).length;
    } catch (e) {
      print('Error getting total notes count: $e');
      return 0;
    }
  }

  /// Fetch memorized (learned) cards count.
  /// Definition: cards with repetition_count > 0 and success review.
  Future<int> getMemorizedNotesCount() async {
    final userId = _userId;
    try {
      final response = await _client
          .from('notes')
          .select('id, user_books!inner(user_id)')
          .eq('user_books.user_id', userId)
          .gt('repetition_count', 0);
      
      return (response as List).length;
    } catch (e) {
      print('Error getting memorized notes count: $e');
      return 0;
    }
  }

  /// Update SRS fields for a note after review
  Future<void> updateNoteSRS(Note note) async {
    try {
      await _client
          .from('notes')
          .update({
            'next_review': note.nextReview?.toIso8601String(),
            'last_review': note.lastReview?.toIso8601String(),
            'review_interval': note.interval,
            'ease_factor': note.easeFactor,
            'repetition_count': note.repetitionCount,
          })
          .eq('id', note.id);
    } catch (e) {
      print('Error updating note SRS: $e');
      rethrow;
    }
  }
}
