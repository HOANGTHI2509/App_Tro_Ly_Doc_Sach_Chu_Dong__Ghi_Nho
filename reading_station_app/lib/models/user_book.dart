import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.dart';

enum BookStatus { reading, wishlist, completed }

class UserBook {
  final String id; // Document ID in Firestore
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

  String get displayImageUrl => customCoverUrl ?? book.imageUrl;

  int get percentage {
    if (book.totalPages == null || book.totalPages == 0) return 0;
    return ((readingProgress / book.totalPages!) * 100).round();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'book': book.toJson(),
      'status': status.name,
      'dateAdded': Timestamp.fromDate(dateAdded),
      'dateCompleted': dateCompleted != null ? Timestamp.fromDate(dateCompleted!) : null,
      'userRating': userRating,
      'readingProgress': readingProgress,
      'notes': notes,
      'customCoverUrl': customCoverUrl,
    };
  }

  factory UserBook.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse status string to enum
    BookStatus parsedStatus = BookStatus.wishlist;
    try {
      parsedStatus = BookStatus.values.firstWhere((e) => e.name == data['status']);
    } catch (_) {}

    return UserBook(
      id: doc.id,
      book: Book.fromFirestore(data['book'] ?? {}),
      status: parsedStatus,
      dateAdded: (data['dateAdded'] as Timestamp).toDate(),
      dateCompleted: data['dateCompleted'] != null ? (data['dateCompleted'] as Timestamp).toDate() : null,
      userRating: data['userRating'],
      readingProgress: data['readingProgress'] ?? 0,
      notes: data['notes'],
      customCoverUrl: data['customCoverUrl'],
    );
  }

  UserBook copyWith({
    BookStatus? status,
    DateTime? dateCompleted,
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
      dateCompleted: dateCompleted ?? this.dateCompleted,
      userRating: userRating ?? this.userRating,
      readingProgress: readingProgress ?? this.readingProgress,
      notes: notes ?? this.notes,
      customCoverUrl: customCoverUrl ?? this.customCoverUrl,
    );
  }
}
