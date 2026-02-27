enum BookStatus { reading, wantToRead, read }

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final BookStatus status;
  final int currentPage;
  final int totalPages;
  final String? genre;
  final double rating;
  final String? finishedDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.status,
    this.currentPage = 0,
    this.totalPages = 0,
    this.genre,
    this.rating = 0.0,
    this.finishedDate,
  });

  double get progress => totalPages > 0 ? currentPage / totalPages : 0.0;
}
