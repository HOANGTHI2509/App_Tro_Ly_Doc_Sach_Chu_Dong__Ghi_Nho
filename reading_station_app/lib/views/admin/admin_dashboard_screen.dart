import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_books_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _metrics;
  String? _errorMsg;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _fetchMetrics();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchMetrics() async {
    try {
      final response = await _supabase.from('system_metrics').select().single();
      if (mounted) {
        setState(() {
          _metrics = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Lỗi tải dữ liệu: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // Màu nền sáng, tinh tế
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFA6400)))
          : _errorMsg != null
              ? _buildErrorState()
              : _buildDashboardContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 32),
             child: Text(_errorMsg!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Thử Lại'),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMsg = null;
              });
              _fetchMetrics();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFA6400),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    final pendingReports = _metrics?["pending_reports"] ?? 0;
    final totalUsers = _metrics?["total_users"] ?? 0;
    final totalBooks = _metrics?["total_master_books"] ?? 0;
    final totalFlashcards = _metrics?["total_flashcards"] ?? 0;
    final totalActivities = _metrics?["total_activities"] ?? 0;

    return RefreshIndicator(
      onRefresh: _fetchMetrics,
      color: const Color(0xFFFA6400),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCards(totalUsers, totalBooks, totalFlashcards, totalActivities),
                    const SizedBox(height: 32),
                    _buildChartSection(totalActivities, totalFlashcards, totalUsers),
                    const SizedBox(height: 80), // Padding cho bottom nav bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFF7F9FC),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFA6400), Color(0xFFFF8A00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(36), bottomRight: Radius.circular(36)),
              ),
            ),
            // Decorative shapes
            Positioned(top: -40, right: -40, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
            Positioned(bottom: 20, left: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Xin chào, Cú Đêm! \u{1F44B}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                    child: IconButton(
                      icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white),
                      onPressed: () => _supabase.auth.signOut(),
                      tooltip: 'Đăng xuất',
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

  Widget _buildOverviewCards(int users, int books, int cards, int acts) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1, 
      children: [
        _buildAnimatedStatCard('Người Dùng', users.toString(), Icons.group_rounded, const Color(0xFF10B981)),
        _buildAnimatedStatCard('Tài Nguyên Sách', books.toString(), Icons.library_books_rounded, const Color(0xFF3B82F6)),
        _buildAnimatedStatCard('Tổng Flashcard', cards.toString(), Icons.style_rounded, const Color(0xFF8B5CF6)),
        _buildAnimatedStatCard('Lượt Tương Tác', acts.toString(), Icons.local_fire_department_rounded, const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _buildAnimatedStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
              // Icon chỉ báo tăng trưởng
              Icon(Icons.trending_up_rounded, color: const Color(0xFF10B981).withOpacity(0.7), size: 20),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.0)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChartSection(int act, int flash, int usr) {
    // Biểu đồ Fake Visual Design (Vì API chỉ trả về con số tổng, ta build UI minh hoạ biểu đồ cột)
    double maxVal = (act > flash && act > usr) ? act.toDouble() : (flash > usr ? flash.toDouble() : usr.toDouble());
    if (maxVal == 0) maxVal = 100; // Tránh c/0

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Bảng màu tối sang trọng
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               const Text('Hoạt động Hệ thống', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                 decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                 child: const Text('Tháng này', style: TextStyle(color: Colors.white70, fontSize: 12)),
               )
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('Người dùng', usr, maxVal, const Color(0xFF10B981)),
              _buildChartBar('Flashcards', flash, maxVal, const Color(0xFF8B5CF6)),
              _buildChartBar('Tương tác', act, maxVal, const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, int value, double maxVal, Color color) {
    final double heightPercent = (value / maxVal).clamp(0.1, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.fastOutSlowIn,
          height: 120 * heightPercent,
          width: 45,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(colors: [color.withOpacity(0.7), color], begin: Alignment.bottomCenter, end: Alignment.topCenter)
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
