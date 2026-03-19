import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note.dart';
import '../../../models/user_book.dart';
import '../../../providers/note_provider.dart';
import 'note_details_screen.dart';

class BookNotesScreen extends ConsumerWidget {
  final UserBook userBook;

  const BookNotesScreen({super.key, required this.userBook});

  final Color _primaryGreen = const Color(0xFF568164);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(bookNotesProvider(userBook.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Ghi chú của sách',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
            Text(
              userBook.book.title,
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Serif',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: notesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: _primaryGreen)),
        error: (err, _) => const Center(child: Text('Đã xảy ra lỗi khi tải ghi chú')),
        data: (notes) {
          if (notes.isEmpty && userBook.summary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có ghi chú nào cho cuốn sách này.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: notes.length + (userBook.summary != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (userBook.summary != null && index == 0) {
                return _buildSummaryCard(context);
              }
              final note = notes[index - (userBook.summary != null ? 1 : 0)];
              return _buildNoteCard(context, note);
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF568164).withOpacity(0.08),
            const Color(0xFF568164).withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF568164).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF568164).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description, color: Color(0xFF568164), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tóm tắt tâm đắc',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF568164),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userBook.summary ?? '',
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF2C3E35),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NoteDetailsScreen(note: note)),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EDE6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      note.pageNumber != null ? 'TRANG ${note.pageNumber}' : 'GHI CHÚ CHUNG',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ),
                  Text(
                    _getFormattedDate(note.createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '“${note.content}”',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  color: Color(0xFF2C3E35),
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.bolt, color: _primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tạo FlashCard',
                    style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  const Icon(Icons.share_outlined, color: Colors.grey, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
