import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/book.dart';
import '../../models/user_book.dart';
import '../../providers/library_provider.dart';
import 'scanner/scanner_screen.dart';

class ManualAddBookScreen extends ConsumerStatefulWidget {
  const ManualAddBookScreen({super.key});

  @override
  ConsumerState<ManualAddBookScreen> createState() => _ManualAddBookScreenState();
}

class _ManualAddBookScreenState extends ConsumerState<ManualAddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final _notesController = TextEditingController();
  
  File? _imageFile;
  bool _isLoading = false;
  BookStatus _status = BookStatus.wishlist;
  
  final List<String> _suggestedCategories = ['Văn học', 'Kinh điển', 'Tâm lý', 'Kinh doanh', 'Lịch sử'];
  final List<String> _selectedCategories = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<String?> _uploadCover(File file) async {
    try {
      final ext = file.path.split('.').last;
      final fileName = 'book_covers/${const Uuid().v4()}.$ext';
      // Dùng chung bucket avatars có sẵn public access cho tiện, phân tách folder book_covers
      final storage = Supabase.instance.client.storage.from('avatars');
      await storage.upload(fileName, file);
      return storage.getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  void _saveBook() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    String? coverUrl;
    if (_imageFile != null) {
      coverUrl = await _uploadCover(_imageFile!);
    }

    final newBookId = 'manual_${const Uuid().v4()}';
    final book = Book(
      id: newBookId,
      title: _titleController.text.trim(),
      authors: _authorController.text.trim().isNotEmpty ? [_authorController.text.trim()] : [],
      author: _authorController.text.trim(),
      imageUrl: coverUrl ?? '',
      totalPages: int.tryParse(_pagesController.text.trim()),
      categories: _selectedCategories,
      description: '',
    );

    final userBook = UserBook(
      id: '', 
      book: book,
      status: _status,
      dateAdded: DateTime.now(),
      notes: _notesController.text.trim(),
      customCoverUrl: coverUrl,
      userRating: null,
      readingProgress: 0,
    );

    try {
      await ref.read(libraryControllerProvider.notifier).addBook(userBook);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu sách vào thư viện')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi thêm sách: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1, bool isRequired = false, String? hint, Widget? prefixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B263B)),
            children: isRequired ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          )
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          validator: isRequired ? (v) => v!.trim().isEmpty ? 'Không được để trống' : null : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: const Color(0xFFF3EFE9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF4C7D64); // Màu xanh chủ đạo của ảnh

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF5), // Nền kem
      appBar: AppBar(
        flexibleSpace: Container(color: const Color(0xFFFAFAF5)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thêm sách mới', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: primaryGreen))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Box Tải ảnh bìa
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 140,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0DFD8),
                        border: Border.all(color: Colors.grey.withOpacity(0.5), style: BorderStyle.solid, width: 2), // Simulate dashed with rounded corners manually or just solid
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(_imageFile!, fit: BoxFit.cover))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, color: Color(0xFF555555), size: 28),
                                ),
                                const SizedBox(height: 8),
                                const Text('Tải ảnh bìa lên', style: TextStyle(color: Color(0xFF666666), fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Thông tin cơ bản
                  const Text('Thông tin cơ bản', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen, fontFamily: 'Serif')),
                  const SizedBox(height: 8),
                  const Text('Hãy bắt đầu bằng việc điền các thông tin quan trọng nhất của cuốn sách bạn muốn lưu giữ.', style: TextStyle(color: Color(0xFF666666), fontSize: 14, height: 1.5)),
                  const SizedBox(height: 16),
                  
                  // Hai nút tùy chọn
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFEBE6DD), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Chọn ảnh mặc định', style: TextStyle(fontSize: 12, color: Color(0xFF444444))),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: const Color(0xFFE0DFD8)), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Quét mã ISBN', style: TextStyle(fontSize: 12, color: Color(0xFF444444))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildTextField('Tên sách', _titleController, isRequired: true, hint: 'Ví dụ: Suối Nguồn'),
                  _buildTextField('Tác giả', _authorController, hint: 'Tên tác giả...', prefixIcon: const Icon(Icons.person, color: Color(0xFF888888))),
                  
                  // Thể loại
                  const Text('Thể loại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B263B))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: [
                      ..._suggestedCategories.map((cat) {
                        final isSelected = _selectedCategories.contains(cat);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) _selectedCategories.remove(cat);
                              else _selectedCategories.add(cat);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryGreen : Colors.transparent,
                              border: Border.all(color: isSelected ? primaryGreen : const Color(0xFFE0DFD8)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF555555), fontSize: 13)),
                          ),
                        );
                      }),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFE6E2D8), borderRadius: BorderRadius.circular(20)),
                        child: const Text('+ Thêm', style: TextStyle(color: primaryGreen, fontSize: 13)),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildTextField('Tổng số trang', _pagesController, isNumber: true, hint: '0'),
                  
                  // Trạng thái đọc
                  const Text('Trạng thái đọc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B263B))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: const Color(0xFFF3EFE9), borderRadius: BorderRadius.circular(16)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<BookStatus>(
                        value: _status,
                        isExpanded: true,
                        dropdownColor: const Color(0xFFF3EFE9),
                        items: const [
                          DropdownMenuItem(value: BookStatus.wishlist, child: Text('Muốn đọc')),
                          DropdownMenuItem(value: BookStatus.reading, child: Text('Đang đọc')),
                          DropdownMenuItem(value: BookStatus.completed, child: Text('Đã xong')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _status = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField('Vị trí & Ghi chú thêm', _notesController, maxLines: 3, hint: 'Ví dụ: Kệ sách phòng khách, Ngăn thứ 2...', prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.location_on, color: Color(0xFF888888)))),
                  
                  // Mẹo nhỏ
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F0E6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Color(0xFF7C6340)),
                            const SizedBox(width: 8),
                            const Text('Mẹo nhỏ từ Terra', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C4728))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('"Việc ghi lại vị trí sách giúp bạn dễ dàng tìm thấy chúng sau này và tạo nên một thư viện có hệ thống hơn."', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF8C7D6B), fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Button Lưu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Lưu vào thư viện', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }
}
