import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _selectedFilter = 'tất cả';

  final List<String> _filters = ['tất cả', 'Atomic Habits', 'Tư duy nhanh và chậm', 'Nhà Giả Kim'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Ghi chú',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: const Color(0xFFFFEBE5),
                    selectedColor: const Color(0xFFFFCCBC),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          // Notes Lists
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNoteCard(
                  bookTitle: 'Atomic Habits',
                  page: 140,
                  content: 'Mục tiêu là để chiến thắng trò chơi, hệ thống là để tiếp tục trò chơi. Đừng tập trung vào đích đến, mà hãy tập trung vào quy trình.',
                  timeAgo: '2 giờ trước',
                  hasFlashcard: false,
                  imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1535115320i/40121378.jpg',
                ),
                _buildNoteCard(
                  bookTitle: 'Tư duy nhanh và chậm',
                  page: 60,
                  content: 'Hệ thống 1 hoạt động tự động và nhanh chóng, với ít hoặc không cần nỗ lực và không cảm giác kiểm soát tự nguyện.',
                  timeAgo: 'Hôm qua',
                  hasFlashcard: true,
                  imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1317793965i/11468377.jpg',
                ),
                 _buildNoteCard(
                  bookTitle: 'Atomic Habits',
                  page: 15,
                  content: 'Nếu bạn muốn có kết quả tốt hơn thì hãy quên việc đặt mục tiêu đi. Thay vào đó hãy tập trung vào hệ thống của bạn.',
                  timeAgo: 'ngày 20/10',
                  hasFlashcard: false,
                  imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1535115320i/40121378.jpg',
                ),
                const SizedBox(height: 60), // padding for FAB
              ],
            ),
          ),
        ],
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF5722),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildNoteCard({
    required String bookTitle,
    required int page,
    required String content,
    required String timeAgo,
    required bool hasFlashcard,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Image + Title + Page
          Row(
            children: [
               ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  imageUrl,
                  height: 40,
                  width: 30,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 40, width: 30, color: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    'trang $page',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              )
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Content
          Text(
            content,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
          ),
           const SizedBox(height: 12),
           const Divider(height: 1),
           const SizedBox(height: 10),

           // Footer: Time + Action
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(
                 timeAgo,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
               ),
               if (hasFlashcard)
                 Row(
                   children: const [
                     Icon(Icons.check, color: Colors.green, size: 18),
                     SizedBox(width: 4),
                     Text('Đã tạo thẻ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                   ],
                 )
                else
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.flash_on, color: Color(0xFFFF5722), size: 18),
                    label: const Text('Tạo FlashCard', style: TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
             ],
           )
        ],
      ),
    );
  }
}
