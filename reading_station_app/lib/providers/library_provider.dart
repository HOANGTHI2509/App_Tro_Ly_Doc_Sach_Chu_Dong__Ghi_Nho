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
      
      // Tạo activity khi thêm sách
      final actType = userBook.status == BookStatus.reading ? 'started_reading' : 'added_book';
      ref.read(communityControllerProvider.notifier).postActivity(
        type: actType,
        bookTitle: userBook.book.title,
        bookImageUrl: userBook.book.imageUrl,
        bookAuthor: userBook.book.author,
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
      
      // Tạo activity khi đọc xong sách
      if (updatedBook.status == BookStatus.completed) {
        ref.read(communityControllerProvider.notifier).postActivity(
          type: 'finished_book',
          bookTitle: updatedBook.book.title,
          bookImageUrl: updatedBook.book.imageUrl,
          bookAuthor: updatedBook.book.author,
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
}

final libraryControllerProvider = AsyncNotifierProvider<LibraryController, void>(LibraryController.new);
