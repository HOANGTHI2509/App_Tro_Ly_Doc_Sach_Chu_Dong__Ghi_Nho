class Flashcard {
  final String id;
  final String? noteId;
  final String userId;
  final String front;
  final String back;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime nextReviewDate;
  final DateTime? lastReviewedAt;
  final DateTime createdAt;

  Flashcard({
    required this.id,
    this.noteId,
    required this.userId,
    required this.front,
    required this.back,
    this.easeFactor = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    required this.nextReviewDate,
    this.lastReviewedAt,
    required this.createdAt,
  });

  factory Flashcard.fromSupabase(Map<String, dynamic> data) {
    return Flashcard(
      id: data['id'],
      noteId: data['note_id'],
      userId: data['user_id'],
      front: data['front'] ?? '',
      back: data['back'] ?? '',
      easeFactor: (data['ease_factor'] ?? 2.5).toDouble(),
      intervalDays: data['interval_days'] ?? 0,
      repetitions: data['repetitions'] ?? 0,
      nextReviewDate: DateTime.parse(data['next_review_date']),
      lastReviewedAt: data['last_reviewed_at'] != null
          ? DateTime.parse(data['last_reviewed_at'])
          : null,
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (noteId != null) 'note_id': noteId,
      'user_id': userId,
      'front': front,
      'back': back,
      'ease_factor': easeFactor,
      'interval_days': intervalDays,
      'repetitions': repetitions,
      'next_review_date': nextReviewDate.toIso8601String(),
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt!.toIso8601String(),
    };
  }

  /// SM-2 Algorithm: Calculate next review based on quality (0-5)
  /// 0-1: Complete blackout / wrong answer
  /// 2-3: Remembered with difficulty
  /// 4-5: Perfect / Easy recall
  Flashcard reviewedWith(int quality) {
    assert(quality >= 0 && quality <= 5);

    double newEF = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (newEF < 1.3) newEF = 1.3;

    int newInterval;
    int newReps;

    if (quality < 3) {
      // Failed: reset
      newInterval = 0;
      newReps = 0;
    } else {
      newReps = repetitions + 1;
      if (newReps == 1) {
        newInterval = 1;
      } else if (newReps == 2) {
        newInterval = 3;
      } else {
        newInterval = (intervalDays * newEF).round();
      }
    }

    return Flashcard(
      id: id,
      noteId: noteId,
      userId: userId,
      front: front,
      back: back,
      easeFactor: newEF,
      intervalDays: newInterval,
      repetitions: newReps,
      nextReviewDate: DateTime.now().add(Duration(days: newInterval == 0 ? 0 : newInterval)),
      lastReviewedAt: DateTime.now(),
      createdAt: createdAt,
    );
  }

  Flashcard copyWith({
    String? front,
    String? back,
  }) {
    return Flashcard(
      id: id,
      noteId: noteId,
      userId: userId,
      front: front ?? this.front,
      back: back ?? this.back,
      easeFactor: easeFactor,
      intervalDays: intervalDays,
      repetitions: repetitions,
      nextReviewDate: nextReviewDate,
      lastReviewedAt: lastReviewedAt,
      createdAt: createdAt,
    );
  }
}
