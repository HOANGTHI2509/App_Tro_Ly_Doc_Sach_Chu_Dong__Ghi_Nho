class Book {
  final String id;
  final String title;
  final String author; // Kept for backwards compatibility with UI
  final List<String> authors;
  final String imageUrl;
  final String description;
  final int? currentPage;
  final int? totalPages;
  final String? genre; // Kept for backwards compatibility
  final List<String> categories;
  final DateTime? completedDate;
  final int? rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.authors = const [],
    required this.imageUrl,
    this.description = '',
    this.currentPage,
    this.totalPages,
    this.genre,
    this.categories = const [],
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
    List<String> authorsList = [];
    if (volumeInfo['authors'] != null && (volumeInfo['authors'] as List).isNotEmpty) {
      authorsList = List<String>.from(volumeInfo['authors']);
      parsedAuthor = authorsList.join(', ');
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
    List<String> categoriesList = [];
    if (volumeInfo['categories'] != null && (volumeInfo['categories'] as List).isNotEmpty) {
      categoriesList = List<String>.from(volumeInfo['categories']);
      parsedGenre = categoriesList.first;
    }

    String parsedDescription = volumeInfo['description'] ?? '';

    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Unknown Title',
      author: parsedAuthor,
      authors: authorsList,
      imageUrl: parsedImageUrl,
      description: parsedDescription,
      totalPages: volumeInfo['pageCount'],
      genre: parsedGenre,
      categories: categoriesList,
    );
  }

  // To/From Database (if making this model generic enough, or we create UserBook later)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'authors': authors,
      'imageUrl': imageUrl,
      'description': description,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'genre': genre,
      'categories': categories,
      'completedDate': completedDate?.toIso8601String(),
      'rating': rating,
    };
  }

  factory Book.fromFirestore(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      authors: List<String>.from(json['authors'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      genre: json['genre'],
      categories: List<String>.from(json['categories'] ?? []),
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
      rating: json['rating'],
    );
  }
}

