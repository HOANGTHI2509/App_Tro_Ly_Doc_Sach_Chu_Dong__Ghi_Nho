import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_book.dart';
import '../../providers/library_provider.dart';
import 'scanner/scanner_screen.dart';
import 'search_book_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/book_item.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  BookStatus _selectedStatus = BookStatus.reading;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _tabAnimController;

  @override
  void initState() {
    super.initState();
    _tabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _tabAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _switchTab(BookStatus status) {
    if (_selectedStatus == status) return;
    _tabAnimController.forward(from: 0);
    setState(() => _selectedStatus = status);
  }

  void _showAddBookBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF8F5), // Màu nền giống ảnh
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24, top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh kéo nhỏ
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thêm sách mới',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif', // Dùng serif hoặc phông chữ sang trọng
                  color: Color(0xFF1B263B), // Màu đậm
                ),
              ),
              const SizedBox(height: 20),
              
              // Nút 1: Quét mã Barcode
              _buildBottomSheetButton(
                icon: Icons.qr_code_scanner, 
                label: 'Quét mã Barcode',
                iconBgColor: const Color(0xFFFFF8F5),
                iconColor: const Color(0xFFFA6400),
                onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
                }
              ),
              const SizedBox(height: 12),

              // Nút 2: Tìm kiếm sách
              _buildBottomSheetButton(
                icon: Icons.search, 
                label: 'Tìm kiếm sách',
                iconBgColor: const Color(0xFFFFF8F5),
                iconColor: const Color(0xFFFA6400),
                onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchBookScreen()));
                }
              ),
              const SizedBox(height: 12),

              // Nút 3: Thêm thủ công
              _buildBottomSheetButton(
                icon: Icons.edit_note, 
                label: 'Thêm thủ công',
                iconBgColor: const Color(0xFFFFF8F5),
                iconColor: const Color(0xFFFA6400),
                onTap: () {
                    Navigator.pop(context);
                    // Handle manual add
                }
              ),

              const SizedBox(height: 30),
              
              // Nút Hủy bỏ
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildBottomSheetButton({
    required IconData icon, 
    required String label, 
    required Color iconBgColor, 
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider theo status đang chọn
    final userBooksAsync = ref.watch(booksByStatusProvider(_selectedStatus));
    
    // Filter by search query
    final String query = _searchController.text.trim().toLowerCase();
    final List<UserBook> displayedBooks = query.isEmpty 
      ? userBooksAsync 
      : userBooksAsync.where((b) => b.book.title.toLowerCase().contains(query)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EB), // Nền màu kem nhạt
      body: SafeArea(
        child: Column(
          children: [
            // Header: Menu, Trạm Đọc, Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Icon(Icons.menu, color: Color(0xFF2C3E35), size: 28),
                   if (_isSearching)
                     Expanded(
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
                         child: TextField(
                           controller: _searchController,
                           autofocus: true,
                           decoration: InputDecoration(
                             hintText: 'Nhập tên sách...',
                             hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                             fillColor: Colors.white,
                             filled: true,
                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                             suffixIcon: IconButton(
                               icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                               onPressed: () {
                                 setState(() {
                                   _searchController.clear();
                                   _isSearching = false;
                                 });
                               },
                             )
                           ),
                           onChanged: (_) => setState(() {}),
                         ),
                       ),
                     )
                   else
                     const Text(
                       'Trạm Đọc',
                       style: TextStyle(
                         fontSize: 22,
                         fontWeight: FontWeight.bold,
                         color: Color(0xFF568164),
                         fontFamily: 'Serif', // Dùng serif font
                       ),
                     ),
                   
                   if (!_isSearching)
                     Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IconButton(
                           icon: const Icon(Icons.search, color: Color(0xFF2C3E35), size: 28),
                           onPressed: () {
                             setState(() {
                               _isSearching = true;
                             });
                           },
                         ),
                         const SizedBox(width: 4),
                         Consumer(
                           builder: (context, ref, _) {
                             // Lấy thông tin user
                             final profileAsync = ref.watch(userProfileProvider);
                             final String? avatarUrl = profileAsync.value?['avatar_url'];
                             final String name = profileAsync.value?['name'] ?? 'A';
                             return CircleAvatar(
                               radius: 17,
                               backgroundColor: const Color(0xFF568164),
                               backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                               child: (avatarUrl == null || avatarUrl.isEmpty)
                                   ? Text(
                                       name.isNotEmpty ? name[0].toUpperCase() : 'A',
                                       style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                     )
                                   : null,
                             );
                           },
                         ),
                       ],
                     ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề lớn
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thư viện', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF2C3E35))),
                          SizedBox(height: 8),
                          Text('Không gian tri thức của riêng bạn', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tabs (Filters)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFilterTab('Đang đọc', BookStatus.reading),
                          const SizedBox(width: 10),
                          _buildFilterTab('Muốn đọc', BookStatus.wishlist),
                          const SizedBox(width: 10),
                          _buildFilterTab('Đã xong', BookStatus.completed),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Danh sách sách
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: anim as Animation<double>, curve: Curves.easeOut)),
                          child: child,
                        ),
                      ),
                      child: displayedBooks.isEmpty
                          ? Padding(
                              key: ValueKey('empty_\$_selectedStatus'),
                              padding: const EdgeInsets.only(top: 60),
                              child: Column(
                                children: [
                                  Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Chưa có sách nào...',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 15),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              key: ValueKey('list_\$_selectedStatus'),
                              children: [
                                ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: displayedBooks.length,
                                  itemBuilder: (context, index) {
                                    return _AnimatedBookItem(
                                      index: index,
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: BookItem(
                                          userBook: displayedBooks[index],
                                          status: _selectedStatus,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (_selectedStatus == BookStatus.completed)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    child: _buildAchievementCard(displayedBooks.length),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 100), // Không gian cho Add button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Dấu cộng
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          heroTag: 'library_fab',
          onPressed: _showAddBookBottomSheet,
          backgroundColor: const Color(0xFF568164),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, BookStatus status) {
    final isSelected = _selectedStatus == status;
    const activeColor = Color(0xFF568164);

    return Expanded(
      child: GestureDetector(
        onTap: () => _switchTab(status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : const Color(0xFFF1EDE6),
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(int bookCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thành tích của bạn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                    color: Color(0xFF1B263B),
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: 'Bạn đã hoàn thành ',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                    children: [
                      TextSpan(
                        text: '$bookCount',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF568164)),
                      ),
                      const TextSpan(text: ' cuốn sách trong năm nay. Tuyệt vời!'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '$bookCount',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF568164),
                  ),
                ),
                const Text(
                  'SÁCH ĐÃ ĐỌC',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ■■■■■■■■■■■■■■■■ Stagger-fade animation for each book card ■■■■■■■■■■■■■■■■
class _AnimatedBookItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedBookItem({required this.child, required this.index});

  @override
  State<_AnimatedBookItem> createState() => _AnimatedBookItemState();
}

class _AnimatedBookItemState extends State<_AnimatedBookItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Stagger: delay each item by 60ms * index (capped at 4)
    final delay = Duration(milliseconds: 60 * widget.index.clamp(0, 4));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
