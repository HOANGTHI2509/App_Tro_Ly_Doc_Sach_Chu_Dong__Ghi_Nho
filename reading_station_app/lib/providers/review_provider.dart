import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../repositories/review_repository.dart';

// Provider for the repository
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

// FutureProvider for due notes
final dueNotesProvider = FutureProvider<List<Note>>((ref) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getDueNotes();
});

// FutureProvider for total cards count
final totalNotesCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getTotalNotesCount();
});

// FutureProvider for memorized cards count
final memorizedNotesCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getMemorizedNotesCount();
});

// FutureProvider for streak count
final streakProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getStreakCount();
});

// FutureProvider for weekly study days
final weeklyStudyDaysProvider = FutureProvider<List<bool>>((ref) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getStudyDaysOfCurrentWeek();
});

// State for Review Session
class ReviewSessionState {
  final List<Note> dueNotes;
  final bool isLoading;
  final String? errorMessage;
  
  ReviewSessionState({
    this.dueNotes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ReviewSessionState copyWith({
    List<Note>? dueNotes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReviewSessionState(
      dueNotes: dueNotes ?? this.dueNotes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ReviewNotifier extends AsyncNotifier<ReviewSessionState> {
  @override
  FutureOr<ReviewSessionState> build() async {
    final notes = await ref.watch(reviewRepositoryProvider).getDueNotes();
    return ReviewSessionState(dueNotes: notes);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final notes = await ref.read(reviewRepositoryProvider).getDueNotes();
      return ReviewSessionState(dueNotes: notes);
    });
  }

  /// SM-2 implementation for updating card review status
  /// q: 0-5 (0 is Again/Blackout, 5 is Perfect)
  Future<int> reviewCard(Note note, int q) async {
    final now = DateTime.now();
    double newEaseFactor = note.easeFactor;
    int newInterval = note.interval;
    int newRepetitionCount = note.repetitionCount;

    if (q >= 3) {
      // Success case
      if (newRepetitionCount == 0) {
         if (q == 3) { newInterval = 2; }
         else if (q == 4) { newInterval = 3; }
         else { newInterval = 5; }
      } else if (newRepetitionCount == 1) {
         if (q == 3) { newInterval = 4; }
         else if (q == 4) { newInterval = 6; }
         else { newInterval = 8; }
      } else {
         if (q == 3) { newInterval = (newInterval * newEaseFactor * 0.8).round(); }
         else if (q == 4) { newInterval = (newInterval * newEaseFactor).round(); }
         else { newInterval = (newInterval * newEaseFactor * 1.3).round(); }
      }
      // Ensure it always grows
      if (newInterval <= note.interval) {
         newInterval = note.interval + 1;
      }

      newRepetitionCount++;
      
      // Update EF: EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
      newEaseFactor = newEaseFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (newEaseFactor < 1.3) newEaseFactor = 1.3;
    } else {
      // Failure case
      newRepetitionCount = 0;
      newInterval = 1;
    }

    final updatedNote = note.copyWith(
      lastReview: now,
      nextReview: now.add(Duration(days: newInterval)),
      interval: newInterval,
      easeFactor: newEaseFactor,
      repetitionCount: newRepetitionCount,
    );

    try {
      await ref.read(reviewRepositoryProvider).updateNoteSRS(updatedNote);
      
      // Refresh state to remove reviewed card from current session or update locally
      final List<Note> currentList = [...(state.value?.dueNotes ?? [])];
      currentList.removeWhere((n) => n.id == note.id);
      
      state = AsyncData(state.value!.copyWith(dueNotes: currentList));
      
      // Invalidate providers
      ref.invalidate(dueNotesProvider);
      ref.invalidate(streakProvider);
      ref.invalidate(weeklyStudyDaysProvider);
      ref.invalidate(memorizedNotesCountProvider);
      return newInterval;
    } catch (e) {
      print('ReviewNotifier error: $e');
      return 1; // Default fallback
    }
  }
}

final reviewNotifierProvider = AsyncNotifierProvider<ReviewNotifier, ReviewSessionState>(ReviewNotifier.new);
