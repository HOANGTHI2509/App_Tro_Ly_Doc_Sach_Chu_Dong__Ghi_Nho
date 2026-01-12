import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import 'library_controller.dart';
import 'widgets/book_card.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final LibraryController _controller = LibraryController();
  
  // Biến trạng thái để kiểm soát việc mở/đóng menu dấu cộng
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = _controller.filteredBooks;
    final isReadingTab = _controller.currentTabIndex == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      
      // 1. App Bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Thư Viện", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black54), onPressed: () {}),
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.black54), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.black54), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),

      // 2. Body dùng Stack để có thể phủ lớp đen mờ lên trên
      body: Stack(
        children: [
          // --- LỚP 1: Nội dung chính (Danh sách sách) ---
          Column(
            children: [
              const SizedBox(height: 10),
              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildTabBtn(0, "Đang đọc"),
                    const SizedBox(width: 10),
                    _buildTabBtn(1, "Muốn đọc"),
                    const SizedBox(width: 10),
                    _buildTabBtn(2, "Đã đọc"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // List Sách
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: books.length + (isReadingTab ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isReadingTab && index == books.length) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 80), // Bottom padding lớn để không bị nút che
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lightbulb_outline, size: 18, color: Colors.grey),
                            SizedBox(width: 5),
                            Text("Gợi ý: Cập nhật tiến độ để duy trì chuỗi đọc", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      );
                    }
                    return BookCard(book: books[index]);
                  },
                ),
              ),
            ],
          ),

          // --- LỚP 2: Màn đen mờ (Chỉ hiện khi _isMenuOpen = true) ---
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu, // Bấm ra ngoài thì đóng menu
              child: Container(
                color: Colors.black.withOpacity(0.6), // Màu đen mờ 60%
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // --- LỚP 3: Các nút menu con (Hiện từ dưới lên) ---
          if (_isMenuOpen)
            Positioned(
              bottom: 80, // Cách đáy khoảng 80px (trên nút FAB)
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // Căn phải
                children: [
                  _buildMenuItemLabel("Thêm ghi chú"),
                  const SizedBox(height: 12),
                  _buildMenuItemLabel("Quét mã Vạch"),
                  const SizedBox(height: 12),
                  _buildMenuItemLabel("Thêm sách"),
                  const SizedBox(height: 12),
                ],
              ),
            ),
        ],
      ),

      // 3. Floating Action Button (Nút to ở góc)
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMenu,
        backgroundColor: const Color(0xFFFA6400), // Màu cam
        elevation: 4,
        shape: const CircleBorder(),
        // Đổi icon: Nếu mở thì hiện dấu X, nếu đóng hiện dấu +
        child: Icon(
          _isMenuOpen ? Icons.close : Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // Widget con: Nút Tab
  Widget _buildTabBtn(int index, String text) {
    bool isSelected = _controller.currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        // Nếu menu đang mở thì đóng lại khi chuyển tab
        if (_isMenuOpen) _toggleMenu(); 
        _controller.changeTab(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
        ),
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  // Widget con: Nút Menu nhỏ (Màu trắng, chữ đen đậm)
  Widget _buildMenuItemLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}