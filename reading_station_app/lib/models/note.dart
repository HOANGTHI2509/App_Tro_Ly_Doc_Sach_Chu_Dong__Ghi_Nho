import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String? id;
  final String userId;
  final String bookTitle;
  final String bookImageUrl;
  final String content;
  final int pageNumber;
  final bool hasFlashcard;
  final DateTime createdAt;

  Note({
    this.id,
    required this.userId,
    required this.bookTitle,
    this.bookImageUrl = '',
    required this.content,
    this.pageNumber = 0,
    this.hasFlashcard = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Firestore serialization
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookTitle': bookTitle,
      'bookImageUrl': bookImageUrl,
      'content': content,
      'pageNumber': pageNumber,
      'hasFlashcard': hasFlashcard,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Note.fromMap(String id, Map<String, dynamic> map) {
    return Note(
      id: id,
      userId: map['userId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      bookImageUrl: map['bookImageUrl'] ?? '',
      content: map['content'] ?? '',
      pageNumber: map['pageNumber'] ?? 0,
      hasFlashcard: map['hasFlashcard'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Note copyWith({
    String? id,
    String? userId,
    String? bookTitle,
    String? bookImageUrl,
    String? content,
    int? pageNumber,
    bool? hasFlashcard,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      content: content ?? this.content,
      pageNumber: pageNumber ?? this.pageNumber,
      hasFlashcard: hasFlashcard ?? this.hasFlashcard,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
