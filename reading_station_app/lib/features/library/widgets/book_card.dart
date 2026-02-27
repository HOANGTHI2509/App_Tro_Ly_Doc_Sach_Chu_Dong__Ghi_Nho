import 'package:flutter/material.dart';
import '../../../models/book_model.dart';

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ảnh bìa sách
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              book.coverUrl,
              width: 70,
              height: 105,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: 70, height: 105, color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 16),
          
          // 2. Thông tin sách bên phải
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(book.author, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 12),

                // Hiển thị widget con tùy theo trạng thái sách
                if (book.status == BookStatus.reading) _buildReadingProgress()
                else if (book.status == BookStatus.wantToRead) _buildWantToReadInfo()
                else _buildReadInfo(),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget con: Thanh tiến độ (Tab Đang đọc)
  Widget _buildReadingProgress() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: book.progress,
            backgroundColor: const Color(0xFFFA6400).withOpacity(0.2),
            color: const Color(0xFFFA6400),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Trang ${book.currentPage}/${book.totalPages}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text("${(book.progress * 100).toInt()}%", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  // Widget con: Thể loại và số trang (Tab Muốn đọc)
  Widget _buildWantToReadInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFA6400).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(book.genre ?? "Chung", style: const TextStyle(color: const Color(0xFFFA6400), fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 6),
        Text("Trang ${book.totalPages}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // Widget con: Đánh giá sao và ngày hoàn thành (Tab Đã đọc)
  Widget _buildReadInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < book.rating ? Icons.star : Icons.star_border,
              color: const Color(0xFFFFC107),
              size: 16,
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 14),
            const SizedBox(width: 4),
            Text("Hoàn thành ${book.finishedDate}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        )
      ],
    );
  }
}