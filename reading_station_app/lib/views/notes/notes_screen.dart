import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note.dart';
import '../../../providers/note_provider.dart';
import '../../../providers/nav_provider.dart';
import 'add_note_screen.dart';
import 'note_details_screen.dart';

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
          final List<String> dynamicFilters = ['Tất cả', ...notes.map((n) => n.bookTitle).toSet().toList()];
          
          final query = _searchController.text.toLowerCase();
          var filteredNotes = notes.where((n) => 
            n.content.toLowerCase().contains(query) || 
            n.bookTitle.toLowerCase().contains(query)).toList();

          if (_selectedFilter != 'Tất cả') {
            filteredNotes = filteredNotes.where((n) => n.bookTitle == _selectedFilter).toList();
          }

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    return InkWell(
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
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  note.bookTitle.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.0),
                ),
                Text(
                  _getRelativeTime(note.createdAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              note.pageNumber != null ? 'Trang ${note.pageNumber}' : 'Ghi chú chung',
              style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey[200]!, width: 2)),
              ),
              child: Text(
                '“${note.content}”',
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w600, 
                  height: 1.6, 
                  color: Color(0xFF2C3E35),
                  fontFamily: 'Serif'
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    final bool isCurrentlyFlashcard = note.isKeyTakeaway ?? false;
                    
                    if (!isCurrentlyFlashcard) {
                      // Nếu muốn tạo mới, hỏi câu hỏi trước
                      _showFlashcardQuestionDialog(context, note);
                    } else {
                      // Nếu muốn hủy, cứ tắt thẳng
                      ref.read(noteControllerProvider.notifier).toggleFlashcardStatus(note.id, false);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (note.isKeyTakeaway ?? false) ? Icons.done_all : Icons.bolt, 
                          color: _primaryGreen, 
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (note.isKeyTakeaway ?? false) ? 'Đã tạo' : 'Tạo FlashCard',
                          style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
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
                      _showDeleteDialog(context, note);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Xóa ghi chú', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
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

  void _showFlashcardQuestionDialog(BuildContext context, Note note) {
    final TextEditingController questionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: _primaryGreen),
            const SizedBox(width: 10),
            const Text('Câu hỏi Flashcard', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thiết lập câu hỏi để bạn tự ôn luyện tốt hơn:'),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 2,
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
              final question = questionController.text.trim();
              await ref.read(noteControllerProvider.notifier).toggleFlashcardStatus(
                note.id, 
                true, 
                question: question.isEmpty ? null : question
              );
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text('Sẵn sàng ôn tập!'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ref.read(navProvider.notifier).setIndex(2);
                        },
                        child: const Text('XEM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  backgroundColor: _primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('TẠO THẺ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  }
}
