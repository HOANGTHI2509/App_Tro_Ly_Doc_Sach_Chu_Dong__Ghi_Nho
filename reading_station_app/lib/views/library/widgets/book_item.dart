import 'package:flutter/material.dart';
import 'package:reading_station_app/models/book.dart';

import '../reading_screen.dart'; 

enum BookStatus { reading, wishlist, completed }

class BookItem extends StatelessWidget {
  final Book book;
  final BookStatus status;

  const BookItem({
    super.key,
    required this.book,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadingScreen(bookTitle: book.title),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(12),
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              book.imageUrl,
              height: 100,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100,
                width: 70,
                color: Colors.grey,
                child: const Icon(Icons.book, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 10),

                // Different UI based on Status
                if (status == BookStatus.reading) _buildReadingStatus(),
                if (status == BookStatus.wishlist) _buildWishlistStatus(),
                if (status == BookStatus.completed) _buildCompletedStatus(),
              ],
            ),
          )
        ],
      ),
    ),
    );
  }

  Widget _buildReadingStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: (book.percentage) / 100,
            backgroundColor: const Color(0xFFFFCCBC),
            color: const Color(0xFFFF5722),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trang ${book.currentPage}/${book.totalPages}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '${book.percentage}%',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWishlistStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
           decoration: BoxDecoration(
             color: const Color(0xFFFFEBE5),
             borderRadius: BorderRadius.circular(10),
           ),
           child: Text(
             book.genre ?? 'Chưa phân loại',
             style: const TextStyle(color: Color(0xFFFF5722), fontSize: 10, fontWeight: FontWeight.bold),
           ),
        ),
        const SizedBox(height: 8),
        Text(
          'Trang ${book.totalPages}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCompletedStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < (book.rating ?? 0) ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 16,
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 14),
            const SizedBox(width: 4),
            Text(
              'Hoàn thành ngày ${_formatDate(book.completedDate)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
