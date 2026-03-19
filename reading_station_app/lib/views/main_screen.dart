import 'package:flutter/material.dart';
import 'library/library_screen.dart';
import 'notes/notes_screen.dart';
import 'review/review_screen.dart';
import 'community/community_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Cập nhật màu cam đồng bộ với app
  final Color _activeColor = const Color(0xFFFA6400);
  final Color _inactiveColor = Colors.grey;

  // Danh sách các màn hình theo thứ tự gốc
  final List<Widget> _screens = [
    const LibraryScreen(),
    const NotesScreen(),
    const ReviewScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao safe area phía dưới (cho iPhone có tai thỏ)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    // Tăng chiều cao tổng thể để tránh lỗi RenderFlex overflow
    final double barTotalHeight = 110.0 + bottomPadding;
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: barTotalHeight,
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Thanh nền trắng của Bottom Bar (giữ chiều cao cố định)
            Container(
              height: 65 + bottomPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
            ),
            // Các Items được dàn hàng ngang (cao hơn thanh nền để có không gian nổi lên)
            Container(
              height: barTotalHeight,
              padding: EdgeInsets.fromLTRB(5, 0, 5, bottomPadding + 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildNavItem(0, Icons.library_books_outlined, Icons.library_books, 'Thư viện'),
                  _buildNavItem(1, Icons.description_outlined, Icons.description, 'Ghi chú'),
                  _buildNavItem(2, Icons.psychology_outlined, Icons.psychology, 'Ôn Tập'),
                  _buildNavItem(3, Icons.people_outline, Icons.people, 'Cộng đồng'),
                  _buildNavItem(4, Icons.person_outline, Icons.person, 'Cá nhân'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        // Chia đều chiều rộng cho 5 phần
        width: MediaQuery.of(context).size.width / 5 - 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Container chứa Icon với hiệu ứng nổi lên và đổ bóng cam
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(bottom: isSelected ? 24 : 0),
              width: isSelected ? 54 : 38,
              height: isSelected ? 54 : 38,
              decoration: BoxDecoration(
                color: isSelected ? _activeColor : Colors.transparent,
                shape: BoxShape.circle,
                // Sửa lỗi shadow: luôn cung cấp list boxShadow để lerp mượt mà
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? _activeColor.withOpacity(0.4) : Colors.transparent,
                    blurRadius: isSelected ? 12 : 0,
                    offset: isSelected ? const Offset(0, 6) : Offset.zero,
                  )
                ],
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : _inactiveColor,
                size: isSelected ? 28 : 24,
              ),
            ),
            const SizedBox(height: 6),
            // Nhãn (Label) bên dưới
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _activeColor : _inactiveColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
