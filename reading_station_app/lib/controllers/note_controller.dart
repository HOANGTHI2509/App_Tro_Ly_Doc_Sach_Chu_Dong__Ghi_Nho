import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/note.dart';

class NoteController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Local state for "Optimistic UI" and fallback when Firebase is broken
  static final List<Note> _sessionNotes = [];
  static final Set<String> _pendingDeletionIds = {};
  static final StreamController<List<Note>> _localStreamController =
      StreamController<List<Note>>.broadcast();

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _notesCollection =>
      _db.collection('notes');

  // Helper to notify listeners of local changes
  void _notifyLocalListeners() {
    _localStreamController.add(List.unmodifiable(_sessionNotes));
  }

  // Get all notes (merged local + firestore)
  Stream<List<Note>> getNotes(String userId) {
    final controller = StreamController<List<Note>>.broadcast();
    List<Note> lastFirestoreNotes = [];

    // Helper to emit the merged list
    void emitMerged() {
      if (controller.isClosed) return;
      
      // 1. Deduplicate
      final localOnlyNotes = _sessionNotes.where((local) {
        return !lastFirestoreNotes.any((sync) => 
          sync.content == local.content && 
          sync.bookTitle == local.bookTitle
        );
      }).toList();

      final allNotes = [...lastFirestoreNotes, ...localOnlyNotes];

      // 2. Filter optimistic deletions
      final filtered = allNotes.where((n) => !_pendingDeletionIds.contains(n.id)).toList();
      
      // 3. Sort by date (just in case)
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      controller.add(filtered);
    }

    // Listen to Firestore
    final firestoreSub = _notesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      lastFirestoreNotes = snapshot.docs
          .map((doc) => Note.fromMap(doc.id, doc.data()))
          .toList();
      emitMerged();
    }, onError: (e) {
      // If Firestore fails, we still have local notes
      emitMerged();
    });

    // Listen to Local events (add, delete, toggle)
    final localSub = _localStreamController.stream.listen((_) {
      emitMerged();
    });

    controller.onCancel = () {
      firestoreSub.cancel();
      localSub.cancel();
    };

    // Initial emit if there are local notes
    if (_sessionNotes.isNotEmpty) emitMerged();

    return controller.stream;
  }

  // Add a new note (Optimistic & Local Fallback)
  Future<String> addNote(Note note) async {
    // Generate a temporary ID for local management if not present
    final localId = note.id ?? 'local_${DateTime.now().millisecondsSinceEpoch}';
    final noteWithId = note.id == null ? note.copyWith(id: localId) : note;

    // Remove from pending deletion if it was somehow there (cleanup)
    _pendingDeletionIds.remove(localId);

    // 1. Add to local session immediately for instant UI update
    _sessionNotes.insert(0, noteWithId);
    _notifyLocalListeners();

    // 2. Attempt Firestore save in the background
    try {
      final docRef = await _notesCollection.add(note.toMap()).timeout(const Duration(seconds: 3));
      
      // Successfully synced! Remove the LOCAL version from session notes 
      // The Firestore stream will now provided the ACTUAL version from server
      _sessionNotes.removeWhere((n) => n.id == localId);
      _notifyLocalListeners();
      
      return docRef.id;
    } catch (e) {
      // Firebase error (stay in local fallback mode with the temp ID)
      return localId;
    }
  }

  // Delete a note (Optimistic)
  Future<void> deleteNote(String noteId) async {
    // 1. Mark as pending deletion for instant UI feedback
    _pendingDeletionIds.add(noteId);
    
    // Also remove from local session if present
    _sessionNotes.removeWhere((n) => n.id == noteId);
    _notifyLocalListeners();

    // 2. Attempt Firestore delete in the background
    try {
      await _notesCollection.doc(noteId).delete().timeout(const Duration(seconds: 3));
    } catch (e) {
       // Silent fallback - if it fails, it stays in _pendingDeletionIds anyway
       // for the current session, ensuring the user doesn't see it again.
    }
  }

  // Toggle flashcard status
  Future<void> toggleFlashcard(String noteId, bool value) async {
    // Update local if present
    for (int i = 0; i < _sessionNotes.length; i++) {
      if (_sessionNotes[i].id == noteId) {
        _sessionNotes[i] = _sessionNotes[i].copyWith(hasFlashcard: value);
      }
    }
    _notifyLocalListeners();

    try {
      await _notesCollection.doc(noteId).update({'hasFlashcard': value}).timeout(const Duration(seconds: 3));
    } catch (e) {
       // Silent fallback
    }
  }
}
