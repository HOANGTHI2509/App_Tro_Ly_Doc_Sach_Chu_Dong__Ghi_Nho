import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_book.dart';
import '../../../providers/note_provider.dart';
import '../user_book_details_screen.dart'; 
import '../../notes/book_notes_screen.dart';
import '../../../providers/library_provider.dart';

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

    if (status == BookStatus.completed) {
      return _buildCompletedItem(context, ref, noteCount);
    }

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
                        color: const Color(0xFF568164), // Xanh mới
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
                      style: const TextStyle(color: Color(0xFF568164), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                    color: const Color(0xFF568164), // Xanh lục
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

  Widget _buildCompletedItem(BuildContext context, WidgetRef ref, int noteCount) {
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
            width: 100,
            height: 140,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(-2, 4))
                      ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: userBook.displayImageUrl.isNotEmpty
                        ? Image.network(
                            userBook.displayImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildFallbackCover(),
                          )
                        : _buildFallbackCover(),
                    ),
                  ),
                ),
                // "Check" Badge
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF568164), 
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 20),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        userBook.book.categories.isNotEmpty ? userBook.book.categories.first.toUpperCase() : 'DANH MỤC',
                        style: const TextStyle(
                          color: Color(0xFF7A6242), 
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 0.5
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        Icons.star, 
                        color: index < (userBook.userRating ?? 5) ? Colors.orange : Colors.grey[300], 
                        size: 12
                      )),
                    )
                  ],
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 4),
                Text(
                  userBook.book.author,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 12),

                // Completion Info
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Hoàn thành: ${_formatDate(userBook.dateCompleted)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                         Navigator.of(context).push(
                           MaterialPageRoute(builder: (context) => BookNotesScreen(userBook: userBook)),
                         );
                      },
                      icon: const Icon(Icons.notes, size: 14),
                      label: const Text('GHI CHÚ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF568164),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showSummaryDialog(context, ref),
                      icon: const Icon(Icons.edit_note, size: 14),
                      label: Text(
                        userBook.summary == null ? 'VIẾT TÓM TẮT' : 'SỬA TÓM TẮT', 
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF568164),
                        side: const BorderSide(color: Color(0xFF568164)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFECE5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share_outlined, size: 18, color: Colors.black87),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    ),
    );
  }

  void _showSummaryDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController summaryController = TextEditingController(text: userBook.summary);
    final Color primaryGreen = const Color(0xFF568164);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.description_outlined, color: primaryGreen),
            const SizedBox(width: 10),
            const Text('Tóm tắt sách', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ghi lại cảm nhận hoặc tóm tắt nội dung cuốn sách "${userBook.book.title}":'),
            const SizedBox(height: 16),
            TextField(
              controller: summaryController,
              autofocus: true,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung tóm tắt...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(libraryControllerProvider.notifier).updateBook(
                userBook.copyWith(
                  summary: summaryController.text.trim().isEmpty ? null : summaryController.text.trim()
                )
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật tóm tắt thành công!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('LƯU LẠI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    // Format: dd/MM/yyyy
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildFallbackCover() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.book, color: Colors.white),
    );
  }
}
