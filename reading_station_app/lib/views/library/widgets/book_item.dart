import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_book.dart';
import '../../../providers/note_provider.dart';
import '../user_book_details_screen.dart'; 

class BookItem extends ConsumerWidget {
  final UserBook userBook;
  final BookStatus status;

  const BookItem({
    super.key,
    required this.userBook,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(bookNotesProvider(userBook.id));
    final noteCount = notesAsync.asData?.value.length ?? 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserBookDetailsScreen(userBook: userBook),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ]
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover Area
          SizedBox(
            width: 90,
            height: 130,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Shadow / Backdrop layer
                Positioned(
                  bottom: -5,
                  left: -5,
                  right: 5,
                  top: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(-3, 5))
                      ]
                    ),
                  ),
                ),
                // Actual Cover
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: userBook.displayImageUrl.isNotEmpty
                      ? Image.network(
                          userBook.displayImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildFallbackCover(),
                        )
                      : _buildFallbackCover(),
                  ),
                ),
                // "X GHI CHÚ" Badge
                if (noteCount > 0)
                  Positioned(
                    top: -8,
                    right: -15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A6242), // Màu nâu nhạt
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$noteCount GHI CHÚ', // Real Note Count
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 24),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  userBook.book.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Serif',
                    color: Color(0xFF1B263B)
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  userBook.book.author,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Biểu đồ Tiến độ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status == BookStatus.reading ? 'TIẾN ĐỘ ĐỌC' : (status == BookStatus.completed ? 'ĐÃ HOÀN THÀNH' : 'ĐỊNH ĐỌC'),
                      style: const TextStyle(color: Color(0xFFFA6400), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    Text(
                      '${userBook.percentage}%',
                      style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (userBook.percentage) / 100,
                    backgroundColor: const Color(0xFFEFECE5), // Nền Track nhạt
                    color: const Color(0xFFFA6400), // Cam
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trang ${userBook.readingProgress} / ${userBook.book.totalPages ?? '?'}',
                  style: TextStyle(color: Colors.grey[800], fontSize: 11),
                ),
              ],
            ),
          )
        ],
      ),
    ),
    );
  }

  Widget _buildFallbackCover() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.book, color: Colors.white),
    );
  }
}
