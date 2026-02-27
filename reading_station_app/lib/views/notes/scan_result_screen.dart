import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/note_controller.dart';
import '../../models/note.dart';

class ScanResultScreen extends StatefulWidget {
  final File? capturedImage;

  const ScanResultScreen({super.key, this.capturedImage});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final NoteController _noteController = NoteController();
  File? _imageFile;
  final _textController = TextEditingController();
  final _pageController = TextEditingController();
  String _selectedBook = 'Dám bị ghét';
  bool _createFlashcard = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageFile = widget.capturedImage;
    // Default demo text matching Figma
    _textController.text =
        'Tự do thực sự là không bị người khác ghét bỏ.Khi bạn sống với đúng bản thân '
        'mình,bạn sẽ không phải sống để làm hài lòng người khác nữa';
    _pageController.text = '128';
  }

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _retakePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  Future<void> _capturePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  Future<void> _saveNote() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung ghi chú')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final note = Note(
      userId: userId,
      bookTitle: _selectedBook,
      content: _textController.text.trim(),
      pageNumber: int.tryParse(_pageController.text) ?? 0,
      hasFlashcard: _createFlashcard,
      // Note: In a real app, you'd upload the _imageFile to Firebase Storage first 
      // and then save the resulting URL to note.bookImageUrl. 
      // For now, we'll just save the text content.
    );

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    await _noteController.addNote(note);

    if (mounted) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã lưu ghi chú thành công!')),
      );
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
        automaticallyImplyLeading: false,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy',
              style: TextStyle(color: Colors.black87, fontSize: 15)),
        ),
        title: const Text(
          'Kết quả quét',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveNote,
            child: const Text('Lưu',
                style: TextStyle(
                    color: Color(0xFFFF5722),
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview section
            _buildImageSection(),

            const SizedBox(height: 16),

            // Text content section
            _buildTextSection(),

            const SizedBox(height: 16),

            // Settings section
            _buildSettingsSection(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
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
          // Image display
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: _imageFile != null
                ? Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: const Color(0xFFE8E0D8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('Chưa có ảnh',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 14)),
                      ],
                    ),
                  ),
          ),

          // Retake button
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: _imageFile != null ? _retakePhoto : _capturePhoto,
              icon: Icon(
                _imageFile != null ? Icons.refresh : Icons.camera_alt_outlined,
                size: 18,
                color: const Color(0xFFFF5722),
              ),
              label: Text(
                _imageFile != null ? 'Chụp lại' : 'Chụp ảnh',
                style: const TextStyle(
                    color: Color(0xFFFF5722), fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF5722)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return Container(
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
      child: TextField(
        controller: _textController,
        maxLines: null,
        minLines: 4,
        style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
        decoration: const InputDecoration(
          hintText: 'Nhập hoặc chỉnh sửa nội dung ghi chú...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
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
          // Book selector
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: const Text('Cuốn sách',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedBook,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ],
            ),
            onTap: _showBookPicker,
          ),

          Divider(height: 1, color: Colors.grey[200]),

          // Page number
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: const Text('Trang số',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            trailing: SizedBox(
              width: 60,
              child: TextField(
                controller: _pageController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFFFF5722),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          // Flashcard toggle
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: const Text('Tạo flashcard',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('Tự động thêm vào lịch ôn tập',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Switch(
              value: _createFlashcard,
              onChanged: (v) => setState(() => _createFlashcard = v),
              activeTrackColor: const Color(0xFFFF5722),
            ),
          ),
        ],
      ),
    );
  }
}
