import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_book.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/note_provider.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  UserBook? _selectedBook;
  final TextEditingController _contentController = TextEditingController();
  final Color _primaryOrange = const Color(0xFFFA6400);
  String _selectedTag = 'Trích dẫn';
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_updateWordCount);
  }

  void _updateWordCount() {
    final text = _contentController.text.trim();
    setState(() {
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateWordCount);
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_selectedBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một cuốn sách!')),
      );
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nội dung ghi chú không được để trống!')),
      );
      return;
    }

    try {
      await ref.read(noteControllerProvider.notifier).addNote(
            _selectedBook!.id,
            _contentController.text.trim(),
            // Có thể thêm tag vào content hoặc xử lý riêng nếu Note model hỗ trợ
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm ghi chú thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(userBooksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ghi chú mới',
          style: TextStyle(color: Color(0xFF2C3E35), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryOrange,
                shape: const StadiumBorder(),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ĐANG ĐỌC TỪ',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
            ),
            const SizedBox(height: 12),
            
            // Thẻ chọn sách
            libraryAsync.when(
              data: (books) {
                // Nếu chưa chọn, mặc định lấy cuốn đầu tiên hoặc hiện nút chọn
                if (_selectedBook == null && books.isNotEmpty) {
                  _selectedBook = books.first;
                }
                
                return GestureDetector(
                  onTap: () => _showBookSelector(books),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: _selectedBook != null && _selectedBook!.displayImageUrl.isNotEmpty
                            ? Image.network(
                                _selectedBook!.displayImageUrl, 
                                width: 45, height: 65, fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 45, height: 65, color: Colors.grey[200], 
                                  child: const Icon(Icons.broken_image, size: 20, color: Colors.grey)
                                ),
                              )
                            : Container(width: 45, height: 65, color: Colors.grey[200], child: const Icon(Icons.book, color: Colors.grey)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedBook?.book.title ?? 'Chọn sách...',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E35)),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedBook?.book.author ?? '',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const Text('Lỗi tải danh sách sách'),
            ),
            
            const SizedBox(height: 24),

            // Nút OCR
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt, color: Color(0xFF2C3E35)),
                label: const Text('OCR / Quét văn bản', style: TextStyle(color: Color(0xFF2C3E35), fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDE8B3), // Màu vàng cam nhạt như ảnh
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Chỗ nhập nội dung
            TextField(
              controller: _contentController,
              maxLines: null,
              style: const TextStyle(fontSize: 18, color: Color(0xFF2C3E35), height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Nội dung ghi chú của bạn...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row các tag
            Row(
              children: [
                const Icon(Icons.local_offer_outlined, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                _buildTagChip('Cảm nhận', const Color(0xFF4F6F52)),
                const SizedBox(width: 8),
                _buildTagChip('Trích dẫn', const Color(0xFF8B7E55)),
                const SizedBox(width: 8),
                _buildTagChip('Câu hỏi', const Color(0xFF6B7280)),
              ],
            ),
            const SizedBox(height: 20),
            
            // Toolbar dưới cùng
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFECE5),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.list, color: Colors.black54), onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo danh sách...')));
                  }),
                  IconButton(icon: const Icon(Icons.image_outlined, color: Colors.black54), onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm ảnh...')));
                  }),
                  IconButton(icon: const Icon(Icons.mic_none, color: Colors.black54), onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ghi âm...')));
                  }),
                  const Spacer(),
                  Text('$_wordCount từ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label, Color color) {
    final isSelected = _selectedTag == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTag = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 3, backgroundColor: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? color : Colors.black54, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  void _showBookSelector(List<UserBook> books) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn sách cho ghi chú', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final b = books[index];
                    return ListTile(
                      leading: Image.network(b.displayImageUrl, width: 40, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.book)),
                      title: Text(b.book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(b.book.author),
                      onTap: () {
                        setState(() => _selectedBook = b);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
