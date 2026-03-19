import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_book.dart';

class LibraryRepository {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.id;
  }

  // Get all user books (single fetch, not stream)
  Future<List<UserBook>> getUserBooks() async {
    try {
      final userId = _userId;
      print('[LibraryRepo] Fetching books for user: $userId');
      
      final data = await _client
          .from('user_books')
          .select()
          .eq('user_id', userId)
          .order('date_added', ascending: false);

      print('[LibraryRepo] Raw data count: ${(data as List).length}');
      
      final books = <UserBook>[];
      for (final doc in data) {
        try {
          books.add(UserBook.fromSupabase(doc));
        } catch (e) {
          print('[LibraryRepo] Error parsing book: $e');
          print('[LibraryRepo] Problematic row: $doc');
        }
      }
      
      print('[LibraryRepo] Successfully parsed ${books.length} books');
      return books;
    } catch (e, st) {
      print('[LibraryRepo] Error getting user books: $e');
      print('[LibraryRepo] Stack: $st');
      return [];
    }
  }

  // Add a new book to the library
  Future<void> addBook(UserBook userBook) async {
    try {
      final userId = _userId;
      
      // Upsert book data to 'books' table just in case it doesn't exist
      await _client.from('books').upsert({
        'id': userBook.book.id,
        'title': userBook.book.title,
        'authors': userBook.book.authors,
        'description': userBook.book.description,
        'cover_image_url': userBook.book.imageUrl,
        'page_count': userBook.book.totalPages,
      });

      await _client.from('user_books').insert(userBook.toSupabase(userId));
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  // Update an existing book (e.g. progress, status)
  Future<void> updateBook(UserBook userBook) async {
    try {
      print('Starting updateBook for id: ${userBook.id}');
      final userId = _userId;
      await _client.from('user_books').update(userBook.toSupabase(userId)).eq('id', userBook.id);
      print('Successfully updated book');
    } catch (e) {
       print('Error updating book in repository: $e');
       rethrow;
    }
  }

  Future<void> updateSummary(String bookId, String summary) async {
    try {
      await _client.from('user_books').update({'summary': summary}).eq('id', bookId);
    } catch (e) {
      print('Error updating summary in repository: $e');
      rethrow;
    }
  }

  // Remove a book
  Future<void> removeBook(String bookId) async {
    try {
      await _client.from('user_books').delete().eq('id', bookId);
    } catch (e) {
       print('Error removing book: $e');
       rethrow;
    }
  }
}

