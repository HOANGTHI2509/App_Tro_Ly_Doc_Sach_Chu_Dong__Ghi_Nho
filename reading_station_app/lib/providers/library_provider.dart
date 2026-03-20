import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_book.dart';
import '../repositories/library_repository.dart';
import 'community_provider.dart';

// Provider for the repository
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository();
});

// FutureProvider that fetches books once and invalidates on changes
final userBooksProvider = FutureProvider<List<UserBook>>((ref) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.getUserBooks();
});

// Provider to filter books by status
final booksByStatusProvider = Provider.family<List<UserBook>, BookStatus>((ref, status) {
  final asyncBooks = ref.watch(userBooksProvider);
  
  return asyncBooks.when(
    data: (books) => books.where((b) => b.status == status).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// AsyncNotifier for actions (add/update/delete)
class LibraryController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> addBook(UserBook userBook) async {
    state = const AsyncLoading();
    try {
      await ref.read(libraryRepositoryProvider).addBook(userBook);
      ref.invalidate(userBooksProvider);

      String type = 'added_book';
      if (userBook.status == BookStatus.reading) type = 'started_reading';
      if (userBook.status == BookStatus.completed) type = 'finished_book';

      ref.read(communityControllerProvider.notifier).postActivity(
        type: type,
        bookTitle: userBook.book.title,
        bookImageUrl: userBook.book.imageUrl,
        bookAuthor: userBook.book.authors.isNotEmpty ? userBook.book.authors.first : '',
        rating: userBook.userRating,
      );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateBook(UserBook updatedBook) async {
    try {
      await ref.read(libraryRepositoryProvider).updateBook(updatedBook);
      ref.invalidate(userBooksProvider);

      if (updatedBook.status == BookStatus.completed) {
        ref.read(communityControllerProvider.notifier).postActivity(
          type: 'finished_book',
          bookTitle: updatedBook.book.title,
          bookImageUrl: updatedBook.book.imageUrl,
          bookAuthor: updatedBook.book.authors.isNotEmpty ? updatedBook.book.authors.first : '',
          rating: updatedBook.userRating,
        );
      }
    } catch (e) {
      print('Error updating book: $e');
      rethrow;
    }
  }

  Future<void> removeBook(String bookId) async {
    try {
      await ref.read(libraryRepositoryProvider).removeBook(bookId);
      ref.invalidate(userBooksProvider);
    } catch (e) {
       print('Error removing book: $e');
    }
  }

  Future<void> updateSummary(String bookId, String summary) async {
    try {
      await ref.read(libraryRepositoryProvider).updateSummary(bookId, summary);
      ref.invalidate(userBooksProvider);
    } catch (e) {
      print('Error updating summary in controller: $e');
    }
  }
}

final libraryControllerProvider = AsyncNotifierProvider<LibraryController, void>(LibraryController.new);
