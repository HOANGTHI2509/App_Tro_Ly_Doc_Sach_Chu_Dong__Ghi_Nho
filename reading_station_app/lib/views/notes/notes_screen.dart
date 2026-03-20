import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note.dart';
import '../../../providers/note_provider.dart';
<<<<<<< HEAD
import '../../../providers/flashcard_provider.dart';
=======
import '../../../providers/nav_provider.dart';
>>>>>>> feature-library
import 'add_note_screen.dart';
import 'note_details_screen.dart';
import 'widgets/create_flashcard_bottom_sheet.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _selectedFilter = 'Tất cả';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final Color _primaryGreen = const Color(0xFF568164); 

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(allNotesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(
        leading: const Icon(Icons.menu, color: Color(0xFF2C3E35)),
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Tìm ghi chú...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              onChanged: (_) => setState(() {}),
            )
          : Text(
            'Ghi chú',
            style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Serif'),
          ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: _primaryGreen),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 17,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=readingstation_user'),
            ),
          )
        ],
      ),
      body: notesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: _primaryGreen)),
        error: (err, _) => const Center(child: Text('Đã xảy ra lỗi tải ghi chú')),
        data: (notes) {
          final List<String> allTags = notes.expand((n) => n.tags ?? <String>[]).toSet().toList();
          final List<String> dynamicFilters = ['Tất cả', ...{...notes.map((n) => n.bookTitle), ...allTags}];
          
          final query = _searchController.text.toLowerCase();
          var filteredNotes = notes.where((n) => 
            n.content.toLowerCase().contains(query) || 
            n.bookTitle.toLowerCase().contains(query)).toList();

          if (_selectedFilter != 'Tất cả') {
            filteredNotes = filteredNotes.where((n) {
              if (n.bookTitle == _selectedFilter) return true;
              if (n.tags != null && n.tags!.contains(_selectedFilter)) return true;
              return false;
            }).toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.tune, color: _primaryGreen),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: const Color(0xFFFBF9F6), // Màu nền kem thật nhạt
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          builder: (context) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.85,
                              minChildSize: 0.5,
                              maxChildSize: 0.95,
                              expand: false,
                              builder: (context, scrollController) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    Center(
                                      child: Container(
                                        width: 40, height: 4,
                                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.black54),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                          const Expanded(
                                            child: Text('Lọc theo bộ sưu tập', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF33604C))),
                                          ),
                                          const SizedBox(width: 48), // Balance for centering
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Expanded(
                                      child: ListView(
                                        controller: scrollController,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                        children: [
                                          const Text('MẶC ĐỊNH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 2.0)),
                                          const SizedBox(height: 12),
                                          _buildFilterListItem(
                                            title: 'Tất cả',
                                            isSelected: _selectedFilter == 'Tất cả',
                                            onTap: () {
                                              setState(() => _selectedFilter = 'Tất cả');
                                              Navigator.pop(context);
                                            },
                                          ),
                                          
                                          if (notes.map((n) => n.bookTitle).toSet().isNotEmpty) ...[
                                            const SizedBox(height: 32),
                                            const Text('THEO SÁCH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 2.0)),
                                            const SizedBox(height: 12),
                                            ...notes.map((n) => n.bookTitle).toSet().map((book) => Padding(
                                              padding: const EdgeInsets.only(bottom: 12),
                                              child: _buildFilterListItem(
                                                title: book,
                                                icon: Icons.menu_book,
                                                isSelected: _selectedFilter == book,
                                                onTap: () {
                                                  setState(() => _selectedFilter = book);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            )),
                                          ],

                                          if (allTags.isNotEmpty) ...[
                                            const SizedBox(height: 20),
                                            const Text('THEO NHÃN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 2.0)),
                                            const SizedBox(height: 16),
                                            Wrap(
                                              spacing: 12,
                                              runSpacing: 12,
                                              children: allTags.map((tag) {
                                                final bool isSelected = _selectedFilter == tag;
                                                final String displayTag = tag.startsWith('#') ? tag.substring(1) : tag; // Strip # for cleaner UI like screenshot
                                                return InkWell(
                                                  onTap: () {
                                                    setState(() => _selectedFilter = tag);
                                                    Navigator.pop(context);
                                                  },
                                                  borderRadius: BorderRadius.circular(24),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? _primaryGreen.withOpacity(0.1) : Colors.transparent,
                                                      border: Border.all(color: isSelected ? _primaryGreen.withOpacity(0.5) : Colors.grey[300]!),
                                                      borderRadius: BorderRadius.circular(24),
                                                    ),
                                                    child: Text(
                                                      displayTag,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                        color: isSelected ? _primaryGreen : Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            )
                                          ],
                                          const SizedBox(height: 40),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                            );
                          },
                        );
                      },
                    ),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                          children: dynamicFilters.map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () => setState(() => _selectedFilter = filter),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? _primaryGreen : const Color(0xFFEFECE5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black54,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: filteredNotes.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('Không tìm thấy ghi chú nào.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        return _buildNoteCard(filteredNotes[index]);
                      },
                    ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'notes_fab',
        onPressed: () => _showAddNoteScreen(),
        backgroundColor: _primaryGreen,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  void _showAddNoteScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddNoteScreen()),
    );
  }

  Widget _buildNoteCard(Note note) {
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
          _showFlashcardBottomSheet(context, note);
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thẻ ghi nhớ này đã được tạo! Bạn có thể xem trong phần Ôn tập.')),
          );
        }
      },
      onDelete: () => _showDeleteDialog(context, note),
      formatDate: _getRelativeTime,
    );
  }

  void _showDeleteDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ghi chú?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(noteControllerProvider.notifier).deleteNote(note.id, note.userBookId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa ghi chú thành công!')),
              );
            },
            child: const Text('XÓA', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFlashcardBottomSheet(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateFlashcardBottomSheet(note: note),
    );
  }
  String _getRelativeTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $day/$month/$year';
  }

  Widget _buildFilterListItem({
    required String title,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F1EA), // Kem đậm xíu như screenshot
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey[300]!, width: 0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: _primaryGreen, size: 20),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                title, 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
<<<<<<< HEAD
            const SizedBox(height: 24),
            InkWell(
              onTap: () => _createFlashcard(note),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: _primaryOrange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tạo FlashCard',
                    style: TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                ],
              ),
            ),
=======
            if (isSelected)
              Icon(Icons.check_circle, color: _primaryGreen, size: 24)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[300], size: 24),
>>>>>>> feature-library
          ],
        ),
      ),
    );
  }
}

<<<<<<< HEAD
  void _createFlashcard(Note note) {
    final frontController = TextEditingController(text: note.content);
    final backController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tạo Flashcard', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mặt trước (Câu hỏi/Trích dẫn):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: frontController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'VD: Định luật 80/20 là gì?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Mặt sau (Đáp án/Giải thích):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: backController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'VD: 80% kết quả đến từ 20% nỗ lực...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (frontController.text.trim().isEmpty || backController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập cả 2 mặt thẻ!')),
                );
                return;
              }
              await ref.read(flashcardControllerProvider.notifier).createFromNote(
                    noteId: note.id,
                    front: frontController.text.trim(),
                    back: backController.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Đã tạo Flashcard! Vào tab Ôn tập để học nhé.'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFA6400),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tạo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${(diff.inDays / 7).floor()} tuần trước';
=======
class _NoteCardItem extends StatefulWidget {
  final Note note;
  final Color primaryGreen;
  final VoidCallback onTap;
  final VoidCallback onFlashcardTap;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDate;

  const _NoteCardItem({
    required this.note,
    required this.primaryGreen,
    required this.onTap,
    required this.onFlashcardTap,
    required this.onDelete,
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
      padding: const EdgeInsets.only(bottom: 20),
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
                      Text(
                        widget.note.bookTitle.toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.0),
                      ),
                      Text(
                        widget.formatDate(widget.note.createdAt),
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.note.pageNumber != null ? 'Trang ${widget.note.pageNumber}' : 'Ghi chú chung',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey[200]!, width: 2)),
                    ),
                    child: MarkdownBody(
                      data: '“${widget.note.content}”',
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w600, 
                          height: 1.6, 
                          color: Color(0xFF2C3E35),
                          fontFamily: 'Serif'
                        ),
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
                  const SizedBox(height: 24),
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
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                        onSelected: (value) {
                          if (value == 'delete') {
                            widget.onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                SizedBox(width: 12),
                                Text('Xóa ghi chú', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
>>>>>>> feature-library
  }
}
