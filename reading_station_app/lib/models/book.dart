class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final int? currentPage;
  final int? totalPages;
  final String? genre;
  final DateTime? completedDate;
  final int? rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    this.currentPage,
    this.totalPages,
    this.genre,
    this.completedDate,
    this.rating,
  });

  // Helper to calculate percentage
  int get percentage {
    if (currentPage == null || totalPages == null || totalPages == 0) return 0;
    return ((currentPage! / totalPages!) * 100).round();
  }

  // Create from Google Books API response
  factory Book.fromGoogleApi(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    
    // Parse authors (can be a list)
    String parsedAuthor = 'Unknown Author';
    if (volumeInfo['authors'] != null && (volumeInfo['authors'] as List).isNotEmpty) {
      parsedAuthor = (volumeInfo['authors'] as List).join(', ');
    }

    // Parse image
    String parsedImageUrl = '';
    if (volumeInfo['imageLinks'] != null) {
      parsedImageUrl = volumeInfo['imageLinks']['thumbnail'] ?? 
                       volumeInfo['imageLinks']['smallThumbnail'] ?? '';
      // Google sometimes returns http, replace with https
      parsedImageUrl = parsedImageUrl.replaceAll('http://', 'https://');
    }

    // Parse Categories
    String? parsedGenre;
     if (volumeInfo['categories'] != null && (volumeInfo['categories'] as List).isNotEmpty) {
      parsedGenre = (volumeInfo['categories'] as List).first;
    }

    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Unknown Title',
      author: parsedAuthor,
      imageUrl: parsedImageUrl,
      totalPages: volumeInfo['pageCount'],
      genre: parsedGenre,
    );
  }

  // To/From Database (if making this model generic enough, or we create UserBook later)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'genre': genre,
      'completedDate': completedDate?.toIso8601String(),
      'rating': rating,
    };
  }

  factory Book.fromFirestore(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      genre: json['genre'],
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
      rating: json['rating'],
    );
  }
}

