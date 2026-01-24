import 'package:flutter/material.dart';
import '../../models/book.dart';
import 'widgets/book_item.dart';
import 'widgets/expandable_fab.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Data
  final List<Book> _readingBooks = [
    Book(
      id: '1',
      title: 'Nhà Giả Kim',
      author: 'Paulo Coelho',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1483412266i/865.jpg',
      currentPage: 120,
      totalPages: 283,
    ),
    Book(
      id: '2',
      title: 'Hành trình về Phương Đông',
      author: 'Baird Thomas Spalding',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1348392160i/15842750.jpg',
      currentPage: 133,
      totalPages: 223,
    ),
  ];

  final List<Book> _wishlistBooks = [
    Book(
      id: '3',
      title: 'Thép đã tôi thế đấy',
      author: 'Nikolai Alekseyevich Ostrovsky',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1348215336l/15808237.jpg',
      genre: 'Tiểu thuyết',
      totalPages: 300,
    ),
    Book(
      id: '4',
      title: 'Đắc nhân tâm',
      author: 'Dale Carnegie',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1449557612l/4865.jpg',
      genre: 'Phát triển bản thân',
      totalPages: 325,
    ),
  ];

  final List<Book> _completedBooks = [
    Book(
      id: '5',
      title: 'Trí tuệ người Do Thái',
      author: 'Jerome Weidman',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1388190013l/20262484.jpg',
      rating: 4,
      completedDate: DateTime(2025, 12, 20),
    ),
    Book(
      id: '6',
      title: 'Hành trình về Phương Đông',
      author: 'Baird Thomas Spalding',
      imageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1348392160i/15842750.jpg',
      rating: 5,
      completedDate: DateTime(2025, 12, 20),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
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
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.black, // Active tab color
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    tabs: const [
                       Tab(child: SizedBox(width: 80, child: Center(child: Text("Đang đọc")))),
                       Tab(child: SizedBox(width: 80, child: Center(child: Text("Muốn đọc")))),
                       Tab(child: SizedBox(width: 80, child: Center(child: Text("Đã đọc")))),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildBookList(_readingBooks, BookStatus.reading),
              _buildBookList(_wishlistBooks, BookStatus.wishlist),
              _buildBookList(_completedBooks, BookStatus.completed),
            ],
          ),
        ),
      ),
      floatingActionButton: const ExpandableFab(),

    );
  }

  Widget _buildBookList(List<Book> books, BookStatus status) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: books.length + (status == BookStatus.reading ? 1 : 0), // +1 for hint
      itemBuilder: (context, index) {
        if (status == BookStatus.reading && index == books.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Gợi ý: Cập nhật tiến độ để duy trì chuỗi đọc',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: BookItem(book: books[index], status: status),
        );
      },
    );
  }

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
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 20;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 20;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.only(bottom: 20),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
