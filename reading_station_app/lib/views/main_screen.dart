import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nav_provider.dart';
import '../providers/review_provider.dart';
import 'library/library_screen.dart';
import 'notes/notes_screen.dart';
import 'review/review_screen.dart';
import 'community/community_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // Cập nhật màu xanh đồng bộ với app mới
  final Color _activeColor = const Color(0xFF568164);
  final Color _inactiveColor = const Color(0xFF8E8E93);

  // Danh sách các màn hình theo thứ tự gốc
  final List<Widget> _screens = [
    const LibraryScreen(),
    const NotesScreen(),
    const ReviewScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  final List<({IconData icon, String label})> _navItems = [
    (icon: Icons.library_books, label: 'Thư viện'),
    (icon: Icons.description, label: 'Ghi chú'),
    (icon: Icons.psychology, label: 'Ôn Tập'),
    (icon: Icons.people, label: 'Cộng đồng'),
    (icon: Icons.person, label: 'Cá nhân'),
  ];

  void _onItemTapped(int index) {
    ref.read(navProvider.notifier).setIndex(index);
    if (index == 2) {
      // Làm mới dữ liệu bên trang Ôn Tập mỗi khi nhấn vào
      ref.invalidate(dueNotesProvider);
      ref.invalidate(totalNotesCountProvider);
      ref.invalidate(memorizedNotesCountProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = ref.watch(navProvider).asData?.value ?? 0;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const double barTotalHeight = 95.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = (screenWidth - 20) / 5; // Khoảng cách giữa các mục
    
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: barTotalHeight + bottomPadding,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Thanh nền trắng
            Container(
              height: 65 + bottomPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
            ),
            
            // Hàng hiển thị bên dưới (Icon + Nhãn)
            Container(
              height: 65 + bottomPadding,
              padding: EdgeInsets.only(bottom: bottomPadding + 8, left: 10, right: 10),
              child: Row(
                children: List.generate(5, (index) => Expanded(
                  child: GestureDetector(
                    onTap: () => _onItemTapped(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon mờ bên dưới, ẩn đi nếu mục đó đang được chọn (đã nổi lên trên)
                        Opacity(
                          opacity: selectedIndex == index ? 0.0 : 1.0,
                          child: Icon(
                            _navItems[index].icon,
                            color: _inactiveColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _navItems[index].label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                            color: selectedIndex == index ? _activeColor : _inactiveColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            ),

            // Nút nổi di chuyển theo index (Vòng tròn)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              bottom: bottomPadding + 32,
              left: 10 + (itemWidth * selectedIndex) + (itemWidth / 2) - 30, // 30 là 1/2 chiều rộng nút 60
              child: GestureDetector(
                onTap: () => _onItemTapped(selectedIndex),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _activeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _activeColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _navItems[selectedIndex].icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
