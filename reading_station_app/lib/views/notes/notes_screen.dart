import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note.dart';
import '../../../providers/note_provider.dart';
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

  final Color _primaryOrange = const Color(0xFFFA6400); 

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
        leading: const Icon(Icons.menu, color: Color(0xFFFA6400)),
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
            style: TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Serif'),
          ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: _primaryOrange),
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
        loading: () => Center(child: CircularProgressIndicator(color: _primaryOrange)),
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
                            color: isSelected ? _primaryOrange : const Color(0xFFEFECE5),
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
        onPressed: () => _showAddNoteScreen(),
        backgroundColor: _primaryOrange,
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
                Icon(Icons.bolt, color: _primaryOrange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tạo FlashCard',
                  style: TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Spacer(),
                const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              ],
            )
          ],
        ),
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
