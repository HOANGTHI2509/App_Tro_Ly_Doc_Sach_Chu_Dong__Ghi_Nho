import 'dart:io';

void main() async {
  print('🧹 Đang tạo lại cấu trúc CHỈ CHO THƯ VIỆN...');

  // 1. Tạo thư mục
  final dirs = [
    'lib/models',
    'lib/features/library',
    'lib/features/library/widgets',
  ];

  for (var dir in dirs) {
    await Directory(dir).create(recursive: true);
    print('✅ Đã tạo: $dir');
  }

  // 2. Tạo File Model (Dữ liệu sách)
  await File('lib/models/book_model.dart').writeAsString('''
enum BookStatus { reading, wantToRead, read }

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final BookStatus status;
  final int currentPage;
  final int totalPages;
  final String? genre;
  final double rating;
  final String? finishedDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.status,
    this.currentPage = 0,
    this.totalPages = 0,
    this.genre,
    this.rating = 0.0,
    this.finishedDate,
  });

  double get progress => totalPages > 0 ? currentPage / totalPages : 0.0;
}
''');

  // 3. Tạo File Controller (Logic)
  await File('lib/features/library/library_controller.dart').writeAsString('''
import 'package:flutter/material.dart';
import '../../models/book_model.dart'; // Lùi 2 cấp ra models

class LibraryController extends ChangeNotifier {
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  final List<Book> _allBooks = [
    Book(id: '1', title: "Nhà Giả Kim", author: "Paulo Coelho", coverUrl: "https://upload.wikimedia.org/wikipedia/vi/9/98/NhagiaKim.jpg", status: BookStatus.reading, currentPage: 120, totalPages: 283),
    Book(id: '2', title: "Thép đã tôi thế đấy", author: "Nikolai Ostrovsky", coverUrl: "https://upload.wikimedia.org/wikipedia/vi/thumb/9/90/Th%C3%A9p_%C4%91%C3%A3_t%C3%B4i_th%E1%BA%BF_%C4%91%E1%BA%A5y_-_B%C3%ACa_s%C3%A1ch_c%E1%BB%A7a_NXB_V%C4%83n_h%E1%BB%8Dc.jpg/220px-Th%C3%A9p_%C4%91%C3%A3_t%C3%B4i_th%E1%BA%BF_%C4%91%E1%BA%A5y_-_B%C3%ACa_s%C3%A1ch_c%E1%BB%A7a_NXB_V%C4%83n_h%E1%BB%8Dc.jpg", status: BookStatus.wantToRead, totalPages: 300, genre: "Tiểu thuyết"),
    Book(id: '3', title: "Trí tuệ Do Thái", author: "Eran Katz", coverUrl: "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1344686737i/15822394.jpg", status: BookStatus.read, rating: 5.0, finishedDate: "20/12/2025"),
  ];

  List<Book> get filteredBooks {
    if (_currentTabIndex == 0) return _allBooks.where((b) => b.status == BookStatus.reading).toList();
    if (_currentTabIndex == 1) return _allBooks.where((b) => b.status == BookStatus.wantToRead).toList();
    return _allBooks.where((b) => b.status == BookStatus.read).toList();
  }

  void changeTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}
''');

  // 4. Tạo File BookCard (Widget hiển thị sách)
  await File('lib/features/library/widgets/book_card.dart').writeAsString('''
import 'package:flutter/material.dart';
import '../../../models/book_model.dart'; // Lùi 3 cấp ra models

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
      child: Row(
        children: [
          Container(width: 70, height: 105, color: Colors.grey[300], child: Image.network(book.coverUrl, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Icon(Icons.book))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(book.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(book.author, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            if(book.status == BookStatus.reading) LinearProgressIndicator(value: book.progress, color: Colors.orange, backgroundColor: Colors.orange.withOpacity(0.2)),
            if(book.status == BookStatus.wantToRead) Text("Tiểu thuyết", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            if(book.status == BookStatus.read) Row(children: [Icon(Icons.star, color: Colors.amber, size: 16), Text(" Đã xong", style: TextStyle(color: Colors.green))]),
          ]))
        ],
      ),
    );
  }
}
''');

  // 5. Tạo File LibraryPage (Màn hình chính)
  await File('lib/features/library/library_page.dart').writeAsString('''
import 'package:flutter/material.dart';
import 'library_controller.dart'; // Cùng thư mục, import trực tiếp
import 'widgets/book_card.dart'; // Vào folder widgets

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final LibraryController _controller = LibraryController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(title: Text("Thư Viện", style: TextStyle(fontWeight: FontWeight.bold)), elevation: 0, backgroundColor: Colors.transparent, foregroundColor: Colors.black),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(children: [
              _tabBtn(0, "Đang đọc"), SizedBox(width: 10),
              _tabBtn(1, "Muốn đọc"), SizedBox(width: 10),
              _tabBtn(2, "Đã đọc"),
            ]),
          ),
          // List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _controller.filteredBooks.length,
              itemBuilder: (ctx, i) => BookCard(book: _controller.filteredBooks[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){}, backgroundColor: Colors.orange, child: Icon(Icons.add, color: Colors.white)),
    );
  }

  Widget _tabBtn(int index, String title) {
    bool isSelected = _controller.currentTabIndex == index;
    return GestureDetector(
      onTap: () => _controller.changeTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
''');

  // 6. Tạo File Main
  await File('lib/main.dart').writeAsString('''
import 'package:flutter/material.dart';
import 'features/library/library_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LibraryPage(), // Chạy thẳng vào trang Thư viện
    );
  }
}
''');

  print('🎉 XONG! Cấu trúc mới đã sẵn sàng. Chạy "flutter run" ngay!');
}