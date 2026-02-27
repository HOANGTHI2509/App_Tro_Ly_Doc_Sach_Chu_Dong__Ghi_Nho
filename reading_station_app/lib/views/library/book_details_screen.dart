import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/book.dart';
import '../../../models/user_book.dart';
import '../../../providers/library_provider.dart';

class BookDetailsScreen extends ConsumerWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Chi tiết sách', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 10)),
                    ]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: book.imageUrl.isNotEmpty
                      ? Image.network(book.imageUrl, width: 140, height: 210, fit: BoxFit.cover, errorBuilder: (_,__,___) => _defaultCover())
                      : _defaultCover(),
                  ),
                ),
              ),
            ),
            
            // Info Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3)),
                  const SizedBox(height: 8),
                  Text(book.author, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  const SizedBox(height: 24),
                  
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Số trang', book.totalPages?.toString() ?? 'N/A'),
                      _buildDivider(),
                      _buildStatColumn('Thể loại', book.genre ?? 'Khác'),
                      _buildDivider(),
                       _buildStatColumn('Đánh giá', 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Description (if available from API, otherwise generic)
                  const Text('Giới thiệu nội dung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    'Dữ liệu giới thiệu chi tiết cho cuốn sách này hiện chưa được cập nhật từ Google Books.',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ]
        ),
        child: ElevatedButton(
          onPressed: () => _showAddConfirmationDialog(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5722),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: const Text('Thêm vào Thư Viện', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _defaultCover() {
    return Container(
      width: 140, height: 210, color: Colors.grey[300],
      child: Icon(Icons.menu_book, size: 50, color: Colors.grey[500])
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: Colors.grey[300]);
  }

  void _showAddConfirmationDialog(BuildContext context, WidgetRef ref) {
    // Check duplicates before showing dialog
    final userLibraryResult = ref.read(userBooksProvider);
    bool isDuplicate = false;
    userLibraryResult.whenData((library) {
       if (library.any((uBook) => uBook.book.id == book.id)) {
          isDuplicate = true;
       }
    });

    if (isDuplicate) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
         content: Text('Sách này đã có trong thư viện của bạn!'),
         backgroundColor: Colors.redAccent,
         behavior: SnackBarBehavior.floating,
       ));
       return;
    }

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
                 Navigator.pop(context); // Close dialog
                 _addBookToLibrary(context, ref, book, BookStatus.wishlist);
               },
               style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
               child: const Text('Muốn đọc', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
               onPressed: () {
                 Navigator.pop(context); // Close dialog
                 _addBookToLibrary(context, ref, book, BookStatus.reading);
               },
               style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
               child: const Text('Đang đọc', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  void _addBookToLibrary(BuildContext context, WidgetRef ref, Book book, BookStatus status) {
     final userBook = UserBook(
        id: '', // Firestore auto-generates
        book: book,
        status: status,
        dateAdded: DateTime.now(),
        dateCompleted: status == BookStatus.completed ? DateTime.now() : null,
     );
     
     ref.read(libraryControllerProvider.notifier).addBook(userBook).then((_) {
       if (context.mounted) {
         // Auto pop the Details screen to return to Search or Library
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
           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
         ));
       }
     });
  }
}
