import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/note_controller.dart';
import '../../models/note.dart';
import 'reading_note_screen.dart';
import 'scan_result_screen.dart';
import 'add_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NoteController _noteController = NoteController();
  late Stream<List<Note>> _notesStream;
  String _selectedFilter = 'tất cả';
  
  // Search states
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  final List<Note> _mockNotes = [
    Note(
      id: 'mock_1',
      userId: 'system',
      bookTitle: 'Atomic Habits',
      content: 'Mục tiêu là để chiến thắng trò chơi, hệ thống là để tiếp tục trò chơi. Đừng tập trung vào đích đến, mà hãy tập trung vào quy trình.',
      pageNumber: 140,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Note(
      id: 'mock_2',
      userId: 'system',
      bookTitle: 'Tư duy nhanh và chậm',
      content: 'Hệ thống 1 hoạt động tự động và nhanh chóng, với ít hoặc không cần nỗ lực và không cảm giác kiểm soát tự nguyện.',
      pageNumber: 60,
      hasFlashcard: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Note(
      id: 'mock_3',
      userId: 'system',
      bookTitle: 'Atomic Habits',
      content: 'Nếu bạn muốn có kết quả tốt hơn thì hãy quên việc đặt mục tiêu đi. Thay vào đó hãy tập trung vào hệ thống của bạn.',
      pageNumber: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _notesStream = _noteController.getNotes(_userId);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm ghi chú...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 18),
              )
            : const Text(
                'Ghi chú',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: false,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching && _searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          final realNotes = snapshot.data ?? [];
          final activeMockNotes = _mockNotes.where((m) => !_deletedMockIds.contains(m.id)).toList();
          List<Note> allNotes = [...realNotes, ...activeMockNotes];
          
          if (_searchQuery.isNotEmpty) {
            allNotes = allNotes.where((n) {
              return n.bookTitle.toLowerCase().contains(_searchQuery) ||
                     n.content.toLowerCase().contains(_searchQuery);
            }).toList();
          }
          allNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (snapshot.connectionState == ConnectionState.waiting && realNotes.isEmpty) {
            return Stack(
              children: [
                _buildNotesContent(allNotes),
                const Positioned(
                  top: 0, left: 0, right: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5722)),
                    minHeight: 2,
                  ),
                ),
              ],
            );
          }

          return _buildNotesContent(allNotes);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        backgroundColor: const Color(0xFFFF5722),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildNotesContent(List<Note> allNotes) {
    // Build filter list from actual book titles
    final bookTitles = allNotes.map((n) => n.bookTitle).toSet().toList();
    final filters = ['tất cả', ...bookTitles];

    // Filter notes
    final filteredNotes = _selectedFilter == 'tất cả'
        ? allNotes
        : allNotes.where((n) => n.bookTitle == _selectedFilter).toList();

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  backgroundColor: const Color(0xFFFFEBE5),
                  selectedColor: const Color(0xFFFFCCBC),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),

        // Notes list
        Expanded(
          child: filteredNotes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredNotes.length + 1,
                  itemBuilder: (context, index) {
                    if (index == filteredNotes.length) {
                      return const SizedBox(height: 60);
                    }
                    return _buildNoteCard(filteredNotes[index]);
                  },
                ),
        ),
      ],
    );
  }



  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có ghi chú nào',
            style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn + để tạo ghi chú mới',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    // Map book titles to cover images
    final bookImages = {
      'Atomic Habits':
          'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1535115320i/40121378.jpg',
      'Tư duy nhanh và chậm':
          'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1317793965i/11468377.jpg',
      'Nhà Giả Kim':
          'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1483412266i/865.jpg',
      'Dám bị ghét':
          'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1516086883i/38128362.jpg',
    };

    final imageUrl = note.bookImageUrl.isNotEmpty
        ? note.bookImageUrl
        : bookImages[note.bookTitle] ?? '';

    final timeAgo = _formatTimeAgo(note.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ReadingNoteScreen(bookTitle: note.bookTitle),
          ),
        );
      },
      onLongPress: () => _showNoteOptions(note),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Image + Title + Page
            Row(
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      imageUrl,
                      height: 40,
                      width: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(height: 40, width: 30, color: Colors.grey[300]),
                    ),
                  ),
                if (imageUrl.isNotEmpty) const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.bookTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (note.pageNumber > 0)
                      Text(
                        'trang ${note.pageNumber}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                  onPressed: () => _showNoteOptions(note),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Content
            Text(
              note.content,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Footer: Time + Flashcard action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeAgo,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                if (note.hasFlashcard)
                  const Row(
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 18),
                      SizedBox(width: 4),
                      Text('Đã tạo thẻ',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  )
                else
                  TextButton.icon(
                    onPressed: () {
                      if (note.id != null) {
                        _noteController.toggleFlashcard(note.id!, true);
                      }
                    },
                    icon: const Icon(Icons.flash_on,
                        color: Color(0xFFFF5722), size: 18),
                    label: const Text('Tạo FlashCard',
                        style: TextStyle(
                            color: Color(0xFFFF5722),
                            fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note, color: Color(0xFFFF5722)),
              title: const Text('Thêm ghi chú mới'),
              subtitle: const Text('Nhập trực tiếp nội dung ghi chú'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddNoteScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_outlined, color: Color(0xFFFF5722)),
              title: const Text('Quét trang sách'),
              subtitle: const Text('Chụp ảnh trang sách để tạo ghi chú'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanResultScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  final Set<String> _deletedMockIds = {};

  void _showNoteOptions(Note note) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xóa ghi chú',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                if (note.id != null) {
                  if (note.id!.startsWith('mock_')) {
                    setState(() {
                      _deletedMockIds.add(note.id!);
                    });
                  } else {
                    _noteController.deleteNote(note.id!);
                  }
                }
              },
            ),
            if (!note.hasFlashcard && note.userId != 'system')
              ListTile(
                leading: const Icon(Icons.flash_on, color: Color(0xFFFF5722)),
                title: const Text('Tạo FlashCard'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (note.id != null) {
                    _noteController.toggleFlashcard(note.id!, true);
                  }
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    return 'ngày ${dateTime.day}/${dateTime.month}';
  }
}
