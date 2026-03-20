import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note.dart';
import '../../../models/user_book.dart';
import '../../../providers/note_provider.dart';
import 'note_details_screen.dart';
import 'widgets/create_flashcard_bottom_sheet.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
    return _NoteCardItem(
      note: note,
      primaryGreen: _primaryGreen,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => NoteDetailsScreen(note: note)),
        );
      },
      onFlashcardTap: () {
        final bool isCurrentlyFlashcard = note.isKeyTakeaway ?? false;
        if (!isCurrentlyFlashcard) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => CreateFlashcardBottomSheet(note: note),
          );
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thẻ ghi nhớ này đã được tạo! Bạn có thể xem trong phần Ôn tập.')),
          );
        }
      },
      formatDate: _getFormattedDate,
    );
  }

  String _getFormattedDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $day/$month/$year';
  }
}

class _NoteCardItem extends StatefulWidget {
  final Note note;
  final Color primaryGreen;
  final VoidCallback onTap;
  final VoidCallback onFlashcardTap;
  final String Function(DateTime) formatDate;

  const _NoteCardItem({
    required this.note,
    required this.primaryGreen,
    required this.onTap,
    required this.onFlashcardTap,
    required this.formatDate,
  });

  @override
  State<_NoteCardItem> createState() => _NoteCardItemState();
}

class _NoteCardItemState extends State<_NoteCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF9FBF9) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? widget.primaryGreen.withOpacity(0.12) : Colors.black.withOpacity(0.04),
                blurRadius: _isHovered ? 25 : 15,
                offset: _isHovered ? const Offset(0, 10) : const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: _isHovered ? widget.primaryGreen.withOpacity(0.3) : Colors.transparent,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            onHover: (hovering) => setState(() => _isHovered = hovering),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                          widget.note.pageNumber != null ? 'TRANG ${widget.note.pageNumber}' : 'GHI CHÚ CHUNG',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),
                      Text(
                        widget.formatDate(widget.note.createdAt),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  MarkdownBody(
                    data: '“${widget.note.content}”',
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                        color: Color(0xFF2C3E35),
                        fontFamily: 'Serif',
                      ),
                    ),
                  ),
                  if (widget.note.tags != null && widget.note.tags!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.note.tags!.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EDE6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      InkWell(
                        onTap: widget.onFlashcardTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                (widget.note.isKeyTakeaway ?? false) ? Icons.done_all : Icons.bolt, 
                                color: widget.primaryGreen, 
                                size: 20
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (widget.note.isKeyTakeaway ?? false) ? 'Đã tạo' : 'Tạo FlashCard',
                                style: TextStyle(color: widget.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.share_outlined, color: Colors.grey, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
