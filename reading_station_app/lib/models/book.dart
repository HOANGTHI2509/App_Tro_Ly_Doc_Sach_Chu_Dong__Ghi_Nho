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
}
