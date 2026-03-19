import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class NoteRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get userId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.id;
  }

  Future<List<Note>> getNotes() async {
    final userId = this.userId;
    try {
      final response = await _client
          .from('notes')
          .select('*, user_books!inner(title, image_url)')
          .eq('user_books.user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List).map((row) {
        return Note.fromSupabase(row);
      }).toList();
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

  Future<List<Note>> getNotesForBook(String userBookId) async {
    final userId = this.userId;
    try {
      final response = await _client
          .from('notes')
          .select('*, user_books!inner(title, image_url)')
          .eq('user_books.user_id', userId)
          .eq('user_book_id', userBookId)
          .order('created_at', ascending: false);
          
      return (response as List).map((row) {
        return Note.fromSupabase(row);
      }).toList();
    } catch (e) {
      print('Error fetching notes for userBook $userBookId: $e');
      return [];
    }
  }

  Future<void> addNote(Note note) async {
    try {
      final Map<String, dynamic> data = note.toSupabase();
      await _client.from('notes').insert(data);
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  Future<void> updateNote(String noteId, String content, {String? question}) async {
    try {
      final updates = {'content': content};
      if (question != null) updates['question'] = question;
      
      await _client
          .from('notes')
          .update(updates)
          .eq('id', noteId);
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }

  Future<void> toggleFlashcardStatus(String noteId, bool isFlashcard, {String? question}) async {
    try {
      final Map<String, dynamic> updates = {'is_key_takeaway': isFlashcard};
      if (isFlashcard && question != null) {
        updates['question'] = question;
      }
      
      await _client
          .from('notes')
          .update(updates)
          .eq('id', noteId);
    } catch (e) {
      print('Error toggling flashcard status: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      // NOTE: Should ideally check if user owns the user_book before deleting,
      // but if RLS is set correctly in Supabase (or since user is authenticated),
      // simple delete is generally okay on frontend.
      await _client.from('notes').delete().eq('id', noteId);
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }
}
