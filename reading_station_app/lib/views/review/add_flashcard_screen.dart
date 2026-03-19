import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_book.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/note_provider.dart';
import '../../../providers/nav_provider.dart';

class AddFlashcardScreen extends ConsumerStatefulWidget {
  const AddFlashcardScreen({super.key});

  @override
  ConsumerState<AddFlashcardScreen> createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends ConsumerState<AddFlashcardScreen> {
  UserBook? _selectedBook;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _pageController = TextEditingController(text: '0');
  final Color _primaryGreen = const Color(0xFF568164);

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveFlashcard() async {
    if (_selectedBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn một cuốn sách!')));
      return;
    }
    if (_questionController.text.trim().isEmpty || _answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Câu hỏi và câu trả lời không được để trống!')));
      return;
    }

    try {
      await ref.read(noteControllerProvider.notifier).addNote(
            _selectedBook!.id,
            _answerController.text.trim(),
            question: _questionController.text.trim(),
            pageNumber: int.tryParse(_pageController.text),
            isKeyTakeaway: true, // This is a flashcard
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã tạo thẻ ghi nhớ thành công!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(userBooksProvider);
    final navIndex = ref.watch(navProvider).value ?? 2; // Default to Review tab

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
          'Tạo Thẻ Ghi Nhớ',
          style: TextStyle(color: Color(0xFF2C3E35), fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Serif'),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _saveFlashcard,
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: _selectedBook != null && _selectedBook!.displayImageUrl.isNotEmpty
                            ? Image.network(_selectedBook!.displayImageUrl, width: 45, height: 65, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.book))
                            : const Icon(Icons.book, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ĐANG CHỌN SÁCH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                _selectedBook?.book.title ?? 'Chọn sách...',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2C3E35), fontFamily: 'Serif'),
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
            
            const SizedBox(height: 16),
            // Vị trí trang
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EFEB).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VỊ TRÍ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Trang ', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: _pageController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E35)),
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mặt trước (Câu hỏi)
            _buildInputSection(
              title: 'MẶT TRƯỚC (CÂU HỎI)',
              icon: Icons.lightbulb_outline,
              hint: 'Nhập câu hỏi hoặc khái niệm cần ghi nhớ...',
              controller: _questionController,
              color: const Color(0xFFE8F1EB).withOpacity(0.5),
            ),

            const SizedBox(height: 20),

            // Mặt sau (Câu trả lời)
            _buildInputSection(
              title: 'MẶT SAU (CÂU TRẢ LỜI)',
              icon: Icons.lightbulb,
              hint: 'Nhập câu trả lời hoặc trích dẫn từ sách...',
              controller: _answerController,
              color: const Color(0xFFF9F1E6).withOpacity(0.5),
            ),

            const SizedBox(height: 30),

            // Nút thêm nhãn / ảnh
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(Icons.tag, 'Thêm nhãn'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(Icons.image_outlined, 'Thêm ảnh'),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navIndex,
        onTap: (index) {
          ref.read(navProvider.notifier).setIndex(index);
          Navigator.pop(context);
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
          BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), activeIcon: Icon(Icons.library_books), label: 'Thư viện'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), activeIcon: Icon(Icons.psychology), label: 'Ôn tập'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }

  Widget _buildInputSection({required String title, required IconData icon, required String hint, required TextEditingController controller, required Color color}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner, size: 16, color: Color(0xFF2C3E35)),
                label: const Text('Quét văn bản', style: TextStyle(fontSize: 11, color: Color(0xFF2C3E35), fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F1EB),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            maxLines: 5,
            style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E35), height: 1.6),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[300]),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFEB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
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
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn sách cho thẻ ghi nhớ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final b = books[index];
                    return ListTile(
                      leading: Image.network(b.displayImageUrl, width: 40, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.book)),
                      title: Text(b.book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
