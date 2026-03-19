import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/book.dart';
import '../../../models/user_book.dart';
import '../../../providers/library_provider.dart';

class BookDetailsScreen extends ConsumerWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  String _getStatusText(BookStatus? status) {
    if (status == BookStatus.reading) return 'Đang đọc';
    if (status == BookStatus.completed) return 'Đã đọc';
    if (status == BookStatus.wishlist) return 'Muốn đọc';
    return 'Chưa thêm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy thông tin sách từ thư viện người dùng
    final libraryAsync = ref.watch(userBooksProvider);
    UserBook? currentLibraryBook;
    
    libraryAsync.whenData((library) {
      try {
        currentLibraryBook = library.firstWhere((ub) => ub.book.id == book.id);
      } catch (_) {}
    });

    final bool inLibrary = currentLibraryBook != null;
    final String statusText = _getStatusText(currentLibraryBook?.status);
    final int progress = currentLibraryBook?.percentage ?? 0;
    final String location = currentLibraryBook?.notes != null && currentLibraryBook!.notes!.isNotEmpty ? currentLibraryBook!.notes! : 'Chưa xếp';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chi tiết sách', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFFFCCBC),
              child: const Icon(Icons.person, size: 20, color: Color(0xFFFA6400)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Ảnh bìa sách
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: book.imageUrl.isNotEmpty
                    ? Image.network(book.imageUrl, width: 180, height: 260, fit: BoxFit.cover, errorBuilder: (_,__,___) => _defaultCover())
                    : _defaultCover(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Trạng thái (Pill)
            if (inLibrary)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0), // Nền cam nhạt
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(color: Color(0xFFFA6400), fontWeight: FontWeight.bold, fontSize: 12), // Text màu cam đậm
                ),
              ),
            const SizedBox(height: 12),

            // Tên sách và Tác giả
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B263B), // Xanh đen
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.author.isNotEmpty ? book.author : 'Không rõ tác giả',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),

            // Hai thẻ: Tiến độ & Vị trí
            if (inLibrary)
              Row(
                children: [
                  Expanded(child: _buildProgressCard(progress)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLocationCard(location)),
                ],
              )
            else 
              _buildAddToLibraryButton(context, ref),

            const SizedBox(height: 20),

            // Hai nút: Ghi chú nhanh & Cho mượn
            if (inLibrary)
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit_note_rounded,
                      label: 'Ghi chú nhanh',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.menu_book,
                      label: 'Cho mượn',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 40),

            // Thông tin chi tiết
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Thông tin chi tiết', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, width: 1.5),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Thể loại', book.categories?.join(', ') ?? 'Tiểu thuyết'),
                  const SizedBox(height: 20),
                  _buildInfoRow('Năm xuất bản', '2019 (Tái bản)'), // Dữ liệu giả định
                  const SizedBox(height: 20),
                  _buildInfoRow('Số trang', book.totalPages?.toString() ?? '300'),
                  const SizedBox(height: 20),
                  _buildInfoRow('Ngôn ngữ', 'Tiếng Việt'), // Dữ liệu giả định
                  const SizedBox(height: 20),
                  _buildInfoRow('ISBN', '978-604-1-15024-5'), // Dữ liệu giả định
                ],
              ),
            ),
            const SizedBox(height: 40), // Khoảng trống dưới cùng
          ],
        ),
      ),
    );
  }

  Widget _defaultCover() {
    return Container(
      width: 180, height: 260, color: Colors.grey[200],
      child: Icon(Icons.menu_book, size: 60, color: Colors.grey[400])
    );
  }

  Widget _buildProgressCard(int progress) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFA6400)), // Màu cam
                ),
                Center(
                  child: Text(
                    '$progress%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tiến độ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLocationCard(String location) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 31),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shelves, size: 45, color: const Color(0xFFE0BB9B)), // Màu gỗ nâu nhạt
          const SizedBox(height: 20),
          Text(location, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 4),
          const Text('Vị trí', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F5), // Nền màu cam rất nhạt
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE8E1), width: 1.5), // Viền cam nhạt
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFD3A38B)), // Màu Icon nâu cam
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFD3A38B),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildAddToLibraryButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _showAddConfirmationDialog(context, ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFA6400),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Text('Thêm vào Thư Viện', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  void _showAddConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Bạn muốn thêm cuốn sách này vào trạng thái nào?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
               onPressed: () {
                 Navigator.pop(context);
                 _addBookToLibrary(context, ref, book, BookStatus.wishlist);
               },
               style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
               child: const Text('Muốn đọc', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
               onPressed: () {
                 Navigator.pop(context);
                 _addBookToLibrary(context, ref, book, BookStatus.reading);
               },
               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFA6400), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
               child: const Text('Đang đọc', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  void _addBookToLibrary(BuildContext context, WidgetRef ref, Book book, BookStatus status) {
     final userBook = UserBook(
        id: '',
        book: book,
        status: status,
        dateAdded: DateTime.now(),
        dateCompleted: status == BookStatus.completed ? DateTime.now() : null,
     );
     
     ref.read(libraryControllerProvider.notifier).addBook(userBook).then((_) {
       if (context.mounted) {
         Navigator.of(context).pop(); 
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
           content: Row(
             children: const [
               Icon(Icons.check_circle, color: Colors.white),
               SizedBox(width: 10),
               Text('Thêm thành công!'),
             ],
           ),
           backgroundColor: Colors.green,
           behavior: SnackBarBehavior.floating,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
         ));
       }
     });
  }
}
