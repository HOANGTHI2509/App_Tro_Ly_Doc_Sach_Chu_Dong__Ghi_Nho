import 'book.dart';

enum BookStatus { reading, wishlist, completed }

class UserBook {
  final String id; // UUID in Supabase
  final Book book;
  final BookStatus status;
  final DateTime dateAdded;
  final DateTime? dateCompleted;
  final int? userRating;
  final int readingProgress; // current page the user is on
  final String? notes; // For tracking physical location or lending status
  final String? customCoverUrl; // Uploaded by user

  UserBook({
    required this.id,
    required this.book,
    required this.status,
    required this.dateAdded,
    this.dateCompleted,
    this.userRating,
    this.readingProgress = 0,
    this.notes,
    this.customCoverUrl,
  });

  String get displayImageUrl => customCoverUrl ?? book.imageUrl ?? '';

  int get percentage {
    if (book.totalPages == null || book.totalPages == 0) return 0;
    return ((readingProgress / book.totalPages!) * 100).round();
  }

  Map<String, dynamic> toSupabase(String userId) {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'book_id': book.id,
      'title': book.title,
      'authors': book.authors,
      'image_url': book.imageUrl,
      'custom_cover_url': customCoverUrl,
      'page_count': book.totalPages,
      'categories': book.categories,
      // Map Dart enum handling
      'status': status == BookStatus.wishlist ? 'Want to read' : (status == BookStatus.reading ? 'Reading' : 'Completed'),
      'current_page': readingProgress,
      'rating': userRating,
      'notes': notes,
      'date_completed': dateCompleted?.toIso8601String(),
    };
  }

  factory UserBook.fromSupabase(Map<String, dynamic> data) {
    BookStatus parsedStatus = BookStatus.wishlist;
    if (data['status'] == 'Reading') {
      parsedStatus = BookStatus.reading;
    } else if (data['status'] == 'Completed') {
      parsedStatus = BookStatus.completed;
    }

    return UserBook(
      id: data['id'],
      book: Book(
        id: data['book_id'] ?? '',
        title: data['title'] ?? '',
        author: List<String>.from(data['authors'] ?? []).join(', '), // Added missing parameter
        authors: List<String>.from(data['authors'] ?? []),
        imageUrl: data['image_url'],
        totalPages: data['page_count'],
        categories: List<String>.from(data['categories'] ?? []),
        description: '', // Can be loaded if joined with books table, but we keep it simple here.
      ),
      status: parsedStatus,
      dateAdded: DateTime.parse(data['date_added']),
      dateCompleted: data['date_completed'] != null ? DateTime.parse(data['date_completed']) : null,
      userRating: data['rating'],
      readingProgress: data['current_page'] ?? 0,
      notes: data['notes'],
      customCoverUrl: data['custom_cover_url'],
    );
  }

  UserBook copyWith({
    BookStatus? status,
    DateTime? dateCompleted,
    bool clearDateCompleted = false,
    int? userRating,
    int? readingProgress,
    String? notes,
    String? customCoverUrl,
  }) {
    return UserBook(
      id: id,
      book: book,
      status: status ?? this.status,
      dateAdded: dateAdded,
      dateCompleted: clearDateCompleted ? null : (dateCompleted ?? this.dateCompleted),
      userRating: userRating ?? this.userRating,
      readingProgress: readingProgress ?? this.readingProgress,
      notes: notes ?? this.notes,
      customCoverUrl: customCoverUrl ?? this.customCoverUrl,
    );
  }
}
