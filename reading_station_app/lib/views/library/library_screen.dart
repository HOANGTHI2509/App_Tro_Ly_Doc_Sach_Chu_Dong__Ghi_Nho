import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_book.dart';
import '../../providers/library_provider.dart';
import 'widgets/book_item.dart';
import 'widgets/expandable_fab.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
              _buildBookList(ref.watch(booksByStatusProvider(BookStatus.reading)), BookStatus.reading),
              _buildBookList(ref.watch(booksByStatusProvider(BookStatus.wishlist)), BookStatus.wishlist),
              _buildBookList(ref.watch(booksByStatusProvider(BookStatus.completed)), BookStatus.completed),
            ],
          ),
        ),
      ),
      floatingActionButton: const ExpandableFab(),

    );
  }

  Widget _buildBookList(List<UserBook> userBooks, BookStatus status) {
    if (userBooks.isEmpty) {
       return Center(
         child: Text(
           'Chưa có sách nào trong danh sách này.',
           style: TextStyle(color: Colors.grey[600]),
         ),
       );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: userBooks.length + (status == BookStatus.reading ? 1 : 0), // +1 for hint
      itemBuilder: (context, index) {
        if (status == BookStatus.reading && index == userBooks.length) {
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
          child: BookItem(userBook: userBooks[index], status: status),
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
