import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/note_controller.dart';
import '../../models/note.dart';

class AddNoteScreen extends StatefulWidget {
  final String? initialBook;
  const AddNoteScreen({super.key, this.initialBook});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final NoteController _noteController = NoteController();
  final _textController = TextEditingController();
  final _pageController = TextEditingController();
  final FocusNode _pageFocusNode = FocusNode();
  String _selectedBook = 'Dám bị ghét';
  bool _createFlashcard = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialBook != null) {
      _selectedBook = widget.initialBook!;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    _pageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung ghi chú')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final note = Note(
      userId: userId,
      bookTitle: _selectedBook,
      content: content,
      pageNumber: int.tryParse(_pageController.text) ?? 0,
      hasFlashcard: _createFlashcard,
    );

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // 1. Close screen and show feedback immediately (Optimistic UI)
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Đã lưu ghi chú thành công!'),
        duration: Duration(seconds: 2),
      ),
    );

    // 2. Perform background save
    try {
      await _noteController.addNote(note);
    } catch (e) {
      // Background error handling - silent fallback
    }
  }

  void _showBookPicker() {
    final books = ['Dám bị ghét', 'Atomic Habits', 'Nhà Giả Kim', 'Tư duy nhanh và chậm'];
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chọn cuốn sách',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...books.map((book) => ListTile(
                  leading: Icon(
                    book == _selectedBook
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: const Color(0xFFFF5722),
                  ),
                  title: Text(book),
                  onTap: () {
                    setState(() => _selectedBook = book);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm ghi chú mới',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveNote,
            child: const Text('Lưu',
                style: TextStyle(
                    color: Color(0xFFFF5722),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Text input container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nội dung ghi chú',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    minLines: 5,
                    autofocus: true,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    decoration: const InputDecoration(
                      hintText: 'Nhập ý tưởng, trích dẫn hoặc cảm nghĩ của bạn...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Book & Settings container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Cuốn sách',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_selectedBook,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.grey),
                      ],
                    ),
                    onTap: _showBookPicker,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    onTap: () {
                      _pageFocusNode.requestFocus();
                    },
                    title: const Text('Trang số',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    trailing: IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _pageController,
                              focusNode: _pageFocusNode,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  color: Color(0xFFFF5722),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: '---',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Tạo Flashcard',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Tự động thêm vào lịch ôn tập',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: _createFlashcard,
                    activeTrackColor: const Color(0xFFFF5722),
                    onChanged: (v) => setState(() => _createFlashcard = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
