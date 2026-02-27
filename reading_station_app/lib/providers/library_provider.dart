import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_book.dart';
import '../repositories/library_repository.dart';

// Provider for the repository
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository();
});

// StreamProvider that automatically listens to Firestore and updates the UI
final userBooksProvider = StreamProvider<List<UserBook>>((ref) {
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
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateBook(UserBook updatedBook) async {
    try {
      await ref.read(libraryRepositoryProvider).updateBook(updatedBook);
    } catch (e) {
      print('Error updating book: $e');
      rethrow;
    }
  }

  Future<void> removeBook(String bookId) async {
    try {
      await ref.read(libraryRepositoryProvider).removeBook(bookId);
    } catch (e) {
    }
  }
}

final libraryControllerProvider = AsyncNotifierProvider<LibraryController, void>(LibraryController.new);
