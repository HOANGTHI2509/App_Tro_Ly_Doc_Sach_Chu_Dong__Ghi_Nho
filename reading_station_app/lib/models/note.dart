import 'package:supabase_flutter/supabase_flutter.dart';

class Note {
  final String id;
  final String userBookId;
  final String content;
  final int? pageNumber;
  final String? imageUrl;
  final bool? isKeyTakeaway;
  final DateTime createdAt;
  final String bookTitle;
  final String bookImageUrl;
  final String bookAuthor;

  Note({
    required this.id,
    required this.userBookId,
    required this.content,
    this.pageNumber,
    this.imageUrl,
    this.isKeyTakeaway,
    required this.createdAt,
    this.bookTitle = '',
    this.bookImageUrl = '',
    this.bookAuthor = '',
  });

  factory Note.fromSupabase(Map<String, dynamic> data) {
    return Note(
      id: data['id'],
      userBookId: data['user_book_id'],
      content: data['content'] ?? '',
      pageNumber: data['page_number'],
      imageUrl: data['image_url'],
      isKeyTakeaway: data['is_key_takeaway'],
      createdAt: DateTime.parse(data['created_at']),
      bookTitle: data['user_books']?['title'] ?? '', // Join từ bảng user_books
      bookImageUrl: data['user_books']?['image_url'] ?? '',
      bookAuthor: data['user_books']?['authors'] != null
        ? List<String>.from(data['user_books']?['authors']).join(', ')
        : '',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_book_id': userBookId,
      'content': content,
      'page_number': pageNumber,
      'image_url': imageUrl,
      if (isKeyTakeaway != null) 'is_key_takeaway': isKeyTakeaway,
      if (id.isNotEmpty) 'created_at': createdAt.toIso8601String(),
    };
  }

  Note copyWith({
    String? content,
    int? pageNumber,
    String? imageUrl,
    bool? isKeyTakeaway,
    String? bookTitle,
    String? bookImageUrl,
  }) {
    return Note(
      id: id,
      userBookId: userBookId,
      content: content ?? this.content,
      pageNumber: pageNumber ?? this.pageNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      isKeyTakeaway: isKeyTakeaway ?? this.isKeyTakeaway,
      createdAt: createdAt,
      bookTitle: bookTitle ?? this.bookTitle,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
    );
  }
}
