import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book App UI',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: false, // Dùng style cũ để dễ khớp design hoặc true tuỳ thích
      ),
      home: const LibraryPage(),
    );
  }
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      // 1. BODY
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thư Viện',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      _buildHeaderIcon(Icons.search),
                      const SizedBox(width: 10),
                      _buildHeaderIcon(Icons.qr_code_scanner),
                      const SizedBox(width: 10),
                      _buildHeaderIcon(Icons.person_outline),
                    ],
                  )
                ],
              ),
              
              const SizedBox(height: 20),

              // Tabs
              Row(
                children: [
                  _buildTabButton('Đang đọc', isActive: true),
                  const SizedBox(width: 10),
                  _buildTabButton('Muốn đọc', isActive: false),
                  const SizedBox(width: 10),
                  _buildTabButton('Đã đọc', isActive: false),
                ],
              ),

              const SizedBox(height: 20),

              // Book Cards
              const BookCard(
                imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1483412266i/865.jpg',
                title: 'Nhà Giả Kim',
                author: 'Paulo Coelho',
                currentPage: 120,
                totalPages: 283,
                percentage: 50,
              ),

              const SizedBox(height: 15),

              const BookCard(
                imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1348392160i/15842750.jpg',
                title: 'Hành trình về Phương Đông',
                author: 'Baird Thomas Spalding',
                currentPage: 133,
                totalPages: 223,
                percentage: 63,
              ),

              const SizedBox(height: 20),

              // Gợi ý
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Gợi ý: Cập nhật tiến độ để duy trì chuỗi đọc',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),

      // 2. FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFFF5722),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      
      // 3. BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFFF5722),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Thư viện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Ghi chú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            label: 'Ôn Tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Cộng đồng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  // --- CÁC HÀM CON (HELPER WIDGETS) NẰM TRONG CLASS STATE ---

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFEBE5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black87, size: 20),
    );
  }

  Widget _buildTabButton(String text, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.black : const Color(0xFFFFEBE5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// --- CLASS WIDGET RIÊNG NẰM NGOÀI CÙNG ---

class BookCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final int currentPage;
  final int totalPages;
  final int percentage;

  const BookCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.author,
    required this.currentPage,
    required this.totalPages,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              imageUrl,
              height: 100,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100, width: 70, color: Colors.grey, child: const Icon(Icons.book),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: const Color(0xFFFFCCBC),
                    color: const Color(0xFFFF5722),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trang $currentPage/$totalPages',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}