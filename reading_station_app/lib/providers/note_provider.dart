import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../repositories/note_repository.dart';
import 'package:uuid/uuid.dart';

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

  Future<void> addNote(String userBookId, String content, {int? pageNumber, String? imageUrl, bool? isKeyTakeaway}) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(noteRepositoryProvider);
      final newNote = Note(
        id: const Uuid().v4(), // Generate UUID off the client
        userBookId: userBookId,
        content: content,
        pageNumber: pageNumber,
        imageUrl: imageUrl,
        isKeyTakeaway: isKeyTakeaway,
        createdAt: DateTime.now(),
      );
      
      await repository.addNote(newNote);
      
      // Invalidate both lists
      ref.invalidate(allNotesProvider);
      ref.invalidate(bookNotesProvider(userBookId));
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateNote(String noteId, String content) async {
    state = const AsyncLoading();
    try {
      await ref.read(noteRepositoryProvider).updateNote(noteId, content);
      ref.invalidate(allNotesProvider);
      // Nếu muốn chính xác cần userBookId, nhưng invalidate allNotes là đủ để UI update
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
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
