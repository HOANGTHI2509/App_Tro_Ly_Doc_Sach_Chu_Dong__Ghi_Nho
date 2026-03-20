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

  /// Check current streak based on last_review dates
  Future<int> getStreakCount() async {
    final userId = _userId;
    try {
      final response = await _client
          .from('notes')
          .select('last_review, user_books!inner(user_id)')
          .eq('user_books.user_id', userId)
          .not('last_review', 'is', null)
          .order('last_review', ascending: false);

      final List<DateTime> dates = (response as List).map((e) {
        return DateTime.parse(e['last_review']).toLocal();
      }).toList();

      if (dates.isEmpty) return 0;
      
      // Group by yyyy-MM-dd
      final distinctDates = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList();
      distinctDates.sort((a, b) => b.compareTo(a));

      int streak = 0;
      DateTime today = DateTime.now();
      today = DateTime(today.year, today.month, today.day);

      if (distinctDates.isEmpty) return 0;
      
      DateTime currentCheck = distinctDates.first;
      // If the most recent review is older than yesterday, streak is 0
      if (currentCheck.isBefore(today.subtract(const Duration(days: 1)))) {
        return 0; 
      }

      for (var date in distinctDates) {
        if (date.isAtSameMomentAs(currentCheck)) {
           streak++;
           currentCheck = currentCheck.subtract(const Duration(days: 1));
        } else {
           break;
        }
      }
      return streak;
    } catch (e) {
      print('Error getting streak count: $e');
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

  /// Get the study days of the current week (from Monday to Sunday)
  Future<List<bool>> getStudyDaysOfCurrentWeek() async {
    final userId = _userId;
    try {
      final response = await _client
          .from('notes')
          .select('last_review')
          .eq('user_books.user_id', userId)
          .not('last_review', 'is', null);

      final List<DateTime> dates = (response as List).map((e) {
        return DateTime.parse(e['last_review']).toLocal();
      }).toList();

      final now = DateTime.now();
      final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
      
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: currentWeekday - 1));
      
      List<bool> weekDays = List.filled(7, false);
      
      for (var date in dates) {
        final d = DateTime(date.year, date.month, date.day);
        final diff = d.difference(startOfWeek).inDays;
        
        if (diff >= 0 && diff < 7) {
          weekDays[diff] = true;
        }
      }
      return weekDays;
    } catch (e) {
      print('Error getting study days: $e');
      return List.filled(7, false);
    }
  }
}
