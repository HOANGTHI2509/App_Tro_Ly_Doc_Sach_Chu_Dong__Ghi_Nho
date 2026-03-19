import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/note.dart';
import '../../../providers/note_provider.dart';

class NoteDetailsScreen extends ConsumerStatefulWidget {
  final Note note;
  const NoteDetailsScreen({super.key, required this.note});

  @override
  ConsumerState<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends ConsumerState<NoteDetailsScreen> {
  late TextEditingController _contentController;
  final Color _primaryGreen = const Color(0xFF568164);
  bool _isBold = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updateNote() async {
    if (_contentController.text.trim().isEmpty) return;
    
    try {
      await ref.read(noteControllerProvider.notifier).updateNote(widget.note.id, _contentController.text.trim());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật ghi chú thành công!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E35)), // Sửa màu tối cho nút quay lại
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết Ghi chú',
          style: TextStyle(color: Color(0xFF2C3E35), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
             padding: const EdgeInsets.only(right: 16),
             child: TextButton(
               onPressed: _updateNote,
               child: Text('Lưu', style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
             ),
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.note.bookImageUrl.isNotEmpty
                          ? Image.network(widget.note.bookImageUrl, width: 68, height: 100, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width:68,height:100,color:Colors.grey[200], child: const Icon(Icons.broken_image)))
                          : Container(width: 68, height: 100, color: Colors.grey[200]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.note.bookTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryGreen)),
                            const SizedBox(height: 4),
                            Text(widget.note.bookAuthor.isNotEmpty ? widget.note.bookAuthor : 'Đang cập nhật', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                            const SizedBox(height: 12),
                            Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(color: const Color(0xFFF2EFEB), borderRadius: BorderRadius.circular(20)),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   const Icon(Icons.menu_book, size: 14, color: Colors.grey),
                                   const SizedBox(width: 6),
                                   Text(widget.note.pageNumber != null ? 'Trang ${widget.note.pageNumber}' : 'Ghi chú chung', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                 ],
                               ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildTag('# Cảm nhận'),
                    const SizedBox(width: 10),
                    _buildTag('# ${widget.note.bookTitle}'),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.grey, size: 28),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng thêm Thẻ đang được phát triển!')));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _contentController,
                  maxLines: null,
                  style: const TextStyle(fontSize: 20, height: 1.6, color: Color(0xFF2C3E35), fontFamily: 'Serif'),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 64,
              margin: const EdgeInsets.only(bottom: 30, left: 24, right: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFECE5),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: Icon(Icons.crop_free, color: _primaryGreen), onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mở OCR / Quét văn bản...')));
                  }),
                  IconButton(icon: Icon(Icons.image_outlined, color: _primaryGreen), onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chọn ảnh từ thư viện...')));
                  }),
                  IconButton(icon: Icon(Icons.mic_none, color: _primaryGreen), onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang lắng nghe giọng nói...')));
                  }),
                  IconButton(icon: Icon(Icons.checklist, color: _primaryGreen), onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo danh sách kiểm tra...')));
                  }),
                  const VerticalDivider(width: 1, indent: 20, endIndent: 20, color: Colors.grey),
                  IconButton(
                    icon: Icon(Icons.format_bold, color: _isBold ? Colors.black : _primaryGreen), 
                    onPressed: () {
                      setState(() => _isBold = !_isBold);
                    }
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDE6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primaryGreen)),
    );
  }
}
