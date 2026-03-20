import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/user_book.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/note_provider.dart';
import '../../../providers/nav_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  UserBook? _selectedBook;
  final TextEditingController _contentController = TextEditingController();
<<<<<<< HEAD
  final TextEditingController _pageController = TextEditingController();
  final Color _primaryOrange = const Color(0xFFFA6400);
  String _selectedTag = 'Trích dẫn';
  int _wordCount = 0;
  final ImagePicker _imagePicker = ImagePicker();
=======
  final TextEditingController _pageController = TextEditingController(text: '0');
  final Color _primaryGreen = const Color(0xFF568164);
  int _wordCount = 0;
  List<String> _selectedTags = [];
>>>>>>> feature-library

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

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _insertFormatting(String prefix, String suffix) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    
    // Nếu chưa có selection cụ thể
    if (selection.baseOffset == -1 || selection.extentOffset == -1) {
      final newText = text + prefix + suffix;
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length - suffix.length),
      );
    } else {
      final start = selection.start;
      final end = selection.end;
      final selectedText = text.substring(start, end);
      final newText = text.replaceRange(start, end, '$prefix$selectedText$suffix');
      
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + prefix.length + selectedText.length),
      );
    }
    _updateWordCount();
  }

  Future<void> _scanText() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đang xử lý hình ảnh...')));
        
        final inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        
        final String text = recognizedText.text;
        if (text.isNotEmpty) {
           setState(() {
              _contentController.text = _contentController.text + (_contentController.text.isNotEmpty ? '\n' : '') + text;
           });
           _updateWordCount();
           if (mounted) {
             ScaffoldMessenger.of(context).hideCurrentSnackBar();
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã quét và thêm văn bản!')));
           }
        } else {
           if (mounted) {
             ScaffoldMessenger.of(context).hideCurrentSnackBar();
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy văn bản trong ảnh.')));
           }
        }
        textRecognizer.close();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi quét: $e')));
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateWordCount);
    _contentController.dispose();
    _pageController.dispose();
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
      final pageNum = _pageController.text.isNotEmpty ? int.tryParse(_pageController.text) : null;
      await ref.read(noteControllerProvider.notifier).addNote(
            _selectedBook!.id,
            _contentController.text.trim(),
<<<<<<< HEAD
            pageNumber: pageNum,
            isKeyTakeaway: _selectedTag == 'Ý chính',
=======
            pageNumber: int.tryParse(_pageController.text),
            isKeyTakeaway: false, // Normal note by default
            tags: _selectedTags.isEmpty ? null : _selectedTags,
>>>>>>> feature-library
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

  void _showAddTagDialog() {
    final TextEditingController tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Nhãn Mới', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(
            hintText: 'Nhập tên nhãn (vd: #quan-trong)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final newTag = tagController.text.trim();
              if (newTag.isNotEmpty) {
                final formattedTag = newTag.startsWith('#') ? newTag : '#$newTag';
                if (!_selectedTags.contains(formattedTag)) {
                  setState(() => _selectedTags.add(formattedTag));
                }
              }
              Navigator.pop(context);
            },
            child: Text('Thêm', style: TextStyle(fontWeight: FontWeight.bold, color: _primaryGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(userBooksProvider);
    final navIndex = ref.watch(navProvider).value ?? 1; // Default to Notes tab if we used it
    final notesAsync = ref.watch(allNotesProvider);
    
    final List<String> availableTags = notesAsync.when(
      data: (notes) {
        final tags = notes.expand((n) => n.tags ?? <String>[]).toSet().toList();
        if (tags.isEmpty) return ['#tamlyhoc', '#thoi_quen', '#trichdan', '#kienthuc'];
        return tags;
      },
      loading: () => ['#tamlyhoc', '#thoi_quen', '#trichdan', '#kienthuc'],
      error: (_,__) => ['#tamlyhoc', '#thoi_quen', '#trichdan', '#kienthuc'],
    );
    final displayTags = {...availableTags, ..._selectedTags}.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ghi chú mới',
          style: TextStyle(
            color: Color(0xFF2C3E35), 
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            fontFamily: 'Serif'
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Thẻ chọn sách
            libraryAsync.when(
              data: (books) {
                if (_selectedBook == null && books.isNotEmpty) {
                  _selectedBook = books.first;
                }
                
                return GestureDetector(
                  onTap: () => _showBookSelector(books),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EFEB),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(2, 2))]
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: _selectedBook != null && _selectedBook!.displayImageUrl.isNotEmpty
                              ? Image.network(
                                  _selectedBook!.displayImageUrl, 
                                  width: 50, height: 75, fit: BoxFit.cover,
                                  errorBuilder: (_,__,___) => _defaultBookIcon(),
                                )
                              : _defaultBookIcon(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ĐANG ĐỌC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                _selectedBook?.book.title ?? 'Chọn sách...',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2C3E35), fontFamily: 'Serif'),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedBook?.book.author ?? '',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.swap_horiz, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const Text('Lỗi tải danh sách sách'),
            ),
            
            const SizedBox(height: 20),

            // Trang số & Quét văn bản
            Row(
              children: [
                const Icon(Icons.menu_book, size: 18, color: Color(0xFF8B7E55)),
                const SizedBox(width: 8),
                const Text('Trang số:', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF2C3E35))),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _pageController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _scanText,
                  icon: const Icon(Icons.camera_alt, color: Color(0xFF212529), size: 18),
                  label: const Text('Quét văn bản', style: TextStyle(color: Color(0xFF212529), fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFD9A5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

<<<<<<< HEAD
            // Nhập số trang
=======
            // Vùng nhập liệu nội dung (Styled)
>>>>>>> feature-library
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.bookmark_outline, color: _primaryOrange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _pageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Số trang (VD: 150)',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Nút OCR
            SizedBox(
              width: double.infinity,
<<<<<<< HEAD
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _pickImageForOCR,
                icon: const Icon(Icons.camera_alt, color: Color(0xFF2C3E35)),
                label: const Text('OCR / Chụp ảnh văn bản', style: TextStyle(color: Color(0xFF2C3E35), fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDE8B3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
=======
              height: 400,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFDEBCC).withOpacity(0.5),
                    const Color(0xFFFDEBCC).withOpacity(0.1),
                  ],
>>>>>>> feature-library
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                   Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      style: const TextStyle(fontSize: 18, color: Color(0xFF2C3E35), height: 1.6),
                      decoration: const InputDecoration(
                        hintText: 'Bắt đầu ghi lại suy nghĩ của bạn...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  
                  // Toolbar
                  const Divider(),
                  Row(
                    children: [
                      _buildToolbarIcon(Icons.format_bold, () => _insertFormatting('**', '**')),
                      _buildToolbarIcon(Icons.format_italic, () => _insertFormatting('*', '*')),
                      _buildToolbarIcon(Icons.format_list_bulleted, () => _insertFormatting('\n- ', '')),
                      _buildToolbarIcon(Icons.format_quote, () => _insertFormatting('\n> ', '')),
                      const Spacer(),
                      Text('$_wordCount TỪ', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            const Text('GỢI Ý:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   ...displayTags.map((tag) => Padding(
                     padding: const EdgeInsets.only(right: 8), 
                     child: _buildTagChip(tag),
                   )),
                   IconButton(
                     icon: Icon(Icons.add_circle, color: _primaryGreen, size: 28),
                     onPressed: _showAddTagDialog,
                     padding: EdgeInsets.zero,
                     constraints: const BoxConstraints(),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
<<<<<<< HEAD
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
                _buildTagChip('Ý chính', const Color(0xFFE65100)),
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
=======
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navIndex,
        onTap: (index) {
          ref.read(navProvider.notifier).setIndex(index);
          Navigator.pop(context); // Go back to main layout which reflects index
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primaryGreen,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), activeIcon: Icon(Icons.library_books), label: 'Tủ sách'),
          BottomNavigationBarItem(icon: Icon(Icons.note_alt_outlined), activeIcon: Icon(Icons.note_alt), label: 'Ghi chú'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.black54, size: 20),
      onPressed: onPressed,
    );
  }

  Widget _buildTagChip(String label) {
    final isSelected = _selectedTags.contains(label);
    return InkWell(
      onTap: () => _toggleTag(label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryGreen : const Color(0xFFEFECE5).withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey, 
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          )
>>>>>>> feature-library
        ),
      ),
    );
  }

  Widget _defaultBookIcon() {
    return Container(width: 50, height: 75, color: Colors.grey[200], child: const Icon(Icons.book, color: Colors.grey, size: 20));
  }

  Future<void> _pickImageForOCR() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📷 Ảnh đã chụp! Tính năng OCR nhận diện chữ sẽ chuyển ảnh thành text tự động.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      // TODO: Integrate google_mlkit_text_recognition for actual OCR
      // final inputImage = InputImage.fromFilePath(image.path);
      // final textRecognizer = TextRecognizer();
      // final recognized = await textRecognizer.processImage(inputImage);
      // _contentController.text += recognized.text;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showBookSelector(List<UserBook> books) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn sách cho ghi chú', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
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
