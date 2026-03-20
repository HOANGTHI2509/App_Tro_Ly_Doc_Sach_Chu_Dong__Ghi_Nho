import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';
import 'review_provider.dart';
import 'package:uuid/uuid.dart';
import 'community_provider.dart';
import 'library_provider.dart';

// Provider for the repository
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

// FutureProvider that fetches ALL notes
final allNotesProvider = FutureProvider<List<Note>>((ref) async {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getNotes();
});

// FutureProvider that fetches notes for a SPECIFIC user_book
final bookNotesProvider = FutureProvider.family<List<Note>, String>((ref, userBookId) async {
  final repository = ref.watch(noteRepositoryProvider);
  return repository.getNotesForBook(userBookId);
});

// AsyncNotifier for actions (add/update/delete)
class NoteController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> addNote(String userBookId, String content, {String? question, int? pageNumber, String? imageUrl, bool? isKeyTakeaway, List<String>? tags}) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(noteRepositoryProvider);
      final newNote = Note(
        id: const Uuid().v4(), // Generate UUID off the client
        userBookId: userBookId,
        content: content,
        question: question,
        pageNumber: pageNumber,
        imageUrl: imageUrl,
        isKeyTakeaway: isKeyTakeaway,
        createdAt: DateTime.now(),
        tags: tags,
      );
      
      await repository.addNote(newNote);
      
      // Invalidate both lists
      ref.invalidate(allNotesProvider);
      ref.invalidate(bookNotesProvider(userBookId));
      
      // Attempt to get book info for the activity feed
      final books = ref.read(userBooksProvider).asData?.value ?? [];
      final book = books.where((b) => b.id == userBookId).firstOrNull;

      ref.read(communityControllerProvider.notifier).postActivity(
        type: 'created_note',
        noteContent: content,
        notePage: pageNumber,
        bookTitle: book?.book.title,
      );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateNote(String noteId, String content, {List<String>? tags}) async {
    state = const AsyncLoading();
    try {
      await ref.read(noteRepositoryProvider).updateNote(noteId, content, tags: tags);
      ref.invalidate(allNotesProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleFlashcardStatus(String noteId, bool isFlashcard, {String? question, String? answer}) async {
    try {
      await ref.read(noteRepositoryProvider).toggleFlashcardStatus(noteId, isFlashcard, question: question, answer: answer);
      ref.invalidate(allNotesProvider);
      
      // Quan trọng: Invalidate các provider bên phía Ôn tập
      ref.invalidate(dueNotesProvider);
      ref.invalidate(totalNotesCountProvider);
    } catch (e) {
      print('Error toggling flashcard status: $e');
    }
  }

  Future<void> deleteNote(String noteId, String userBookId) async {
    try {
      await ref.read(noteRepositoryProvider).deleteNote(noteId);
      ref.invalidate(allNotesProvider);
      ref.invalidate(bookNotesProvider(userBookId));
    } catch (e) {
      print('Error removing note: $e');
    }
  }
}

final noteControllerProvider = AsyncNotifierProvider<NoteController, void>(NoteController.new);
