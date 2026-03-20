import 'package:supabase_flutter/supabase_flutter.dart';

class Note {
  final String id;
  final String userBookId;
  final String content;       // This acts as the ANSWER in flashcards
  final String? question;      // This acts as the QUESTION in flashcards
  final int? pageNumber;
  final String? imageUrl;
  final bool? isKeyTakeaway;
  final DateTime createdAt;
  final String bookTitle;
  final String bookImageUrl;
  final String bookAuthor;

  final DateTime? nextReview;
  final DateTime? lastReview;
  final int interval; // days
  final double easeFactor;
  final int repetitionCount;
  final List<String>? tags;

  Note({
    required this.id,
    required this.userBookId,
    required this.content,
    this.question,
    this.pageNumber,
    this.imageUrl,
    this.isKeyTakeaway,
    required this.createdAt,
    this.bookTitle = '',
    this.bookImageUrl = '',
    this.bookAuthor = '',
    this.nextReview,
    this.lastReview,
    this.interval = 0,
    this.easeFactor = 2.5,
    this.repetitionCount = 0,
    this.tags,
  });

  factory Note.fromSupabase(Map<String, dynamic> data) {
    return Note(
      id: data['id'] ?? '',
      userBookId: data['user_book_id'] ?? '',
      content: data['content'] ?? '',
      question: data['question'],
      pageNumber: data['page_number'],
      imageUrl: data['image_url'],
      isKeyTakeaway: data['is_key_takeaway'],
      createdAt: DateTime.parse(data['created_at']),
      bookTitle: data['user_books']?['title'] ?? '',
      bookImageUrl: data['user_books']?['image_url'] ?? '',
      bookAuthor: (data['user_books']?['authors'] != null)
        ? (data['user_books']?['authors'] is List 
            ? (data['user_books']?['authors'] as List).join(', ')
            : data['user_books']?['authors'].toString()) ?? ''
        : '',
      nextReview: data['next_review'] != null ? DateTime.parse(data['next_review']) : null,
      lastReview: data['last_review'] != null ? DateTime.parse(data['last_review']) : null,
      interval: data['review_interval'] ?? 0,
      easeFactor: (data['ease_factor'] ?? 2.5).toDouble(),
      repetitionCount: data['repetition_count'] ?? 0,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_book_id': userBookId,
      'content': content,
      'question': question,
      'page_number': pageNumber,
      'image_url': imageUrl,
      if (isKeyTakeaway != null) 'is_key_takeaway': isKeyTakeaway,
      if (id.isNotEmpty) 'created_at': createdAt.toIso8601String(),
      'next_review': nextReview?.toIso8601String(),
      'last_review': lastReview?.toIso8601String(),
      'review_interval': interval,
      'ease_factor': easeFactor,
      'repetition_count': repetitionCount,
      if (tags != null) 'tags': tags,
    };
  }

  Note copyWith({
    String? content,
    String? question,
    int? pageNumber,
    String? imageUrl,
    bool? isKeyTakeaway,
    String? bookTitle,
    String? bookImageUrl,
    DateTime? nextReview,
    DateTime? lastReview,
    int? interval,
    double? easeFactor,
    int? repetitionCount,
    List<String>? tags,
  }) {
    return Note(
      id: id,
      userBookId: userBookId,
      content: content ?? this.content,
      question: question ?? this.question,
      pageNumber: pageNumber ?? this.pageNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      isKeyTakeaway: isKeyTakeaway ?? this.isKeyTakeaway,
      createdAt: createdAt,
      bookTitle: bookTitle ?? this.bookTitle,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      nextReview: nextReview ?? this.nextReview,
      lastReview: lastReview ?? this.lastReview,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      tags: tags ?? this.tags,
    );
  }
}
