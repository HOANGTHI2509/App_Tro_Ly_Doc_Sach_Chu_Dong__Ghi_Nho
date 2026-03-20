import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nav_provider.dart';
import '../providers/review_provider.dart';
import 'library/library_screen.dart';
import 'notes/notes_screen.dart';
import 'review/review_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/review_settings_provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowMorningPopup();
    });
  }

  Future<void> _checkAndShowMorningPopup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final lastShownDate = prefs.getString('last_morning_popup_date');
      
      if (lastShownDate == todayStr) return; 

      final settings = await ref.read(reviewSettingsProvider.future);
      final timeStr = settings.notificationTime; // "08:00 AM"
      
      final parts = timeStr.split(' ');
      if (parts.isEmpty) return;
      final hm = parts[0].split(':');
      int h = int.parse(hm[0]);
      int m = int.parse(hm[1]);
      if (parts.length > 1) {
        if (parts[1] == 'PM' && h < 12) h += 12;
        if (parts[1] == 'AM' && h == 12) h = 0;
      }
      
      final now = DateTime.now();
      final notifTime = DateTime(now.year, now.month, now.day, h, m);
      
      if (now.isAfter(notifTime) || now.isAtSameMomentAs(notifTime)) {
        final notes = await ref.read(dueNotesProvider.future);
        if (notes.isNotEmpty) {
          await prefs.setString('last_morning_popup_date', todayStr);
          if (!mounted) return;
          _showMorningPopup(notes.length);
        }
      }
    } catch (_) {}
  }

  void _showMorningPopup(int count) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE5D5C5), Color(0xFFD6C8B8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_fire_department, color: Color(0xFF8B6B4A), size: 40),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B6B4A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Consumer(builder: (context, cRef, _) {
                          final streakAsync = cRef.watch(streakProvider);
                          final val = streakAsync.asData?.value ?? 0;
                          return Text('STREAK: $val NGÀY', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5));
                        }),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Chào buổi sáng,\nOakley!',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Color(0xFF2C3E35), height: 1.2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text.rich(
                        TextSpan(
                          text: 'Hôm nay bạn có ',
                          style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.5),
                          children: [
                            TextSpan(text: '$count thẻ', style: const TextStyle(color: Color(0xFF568164), fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' cần ôn tập để duy trì chuỗi ngày học tập.'),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _onItemTapped(2);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF568164),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('Bắt đầu ôn tập ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('Để sau', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

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
