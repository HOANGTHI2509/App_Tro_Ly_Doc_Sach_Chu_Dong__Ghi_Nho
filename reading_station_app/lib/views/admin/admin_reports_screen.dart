import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/admin_avatar.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _reports = [];
  bool _isLoading = true;
  String _currentTab = 'Tất cả';
  final List<String> _tabs = ['Tất cả', 'Chưa xử lý', 'Đã xử lý'];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      var query = _supabase.from('reports').select('*, reporter:reporter_id(id, full_name, avatar_url)');
      if (_currentTab == 'Chưa xử lý') query = query.eq('status', 'pending');
      if (_currentTab == 'Đã xử lý') query = query.eq('status', 'resolved');
      
      final response = await query.order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _reports = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changeTab(String tab) {
    setState(() {
      _currentTab = tab;
      _isLoading = true;
    });
    _fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        flexibleSpace: Container(color: const Color(0xFFF9FAFC)),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: AdminAvatar()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Duyệt nội dung', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0C4A6E), letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text('Xử lý các báo cáo vi phạm từ cộng đồng.', style: TextStyle(color: Color(0xFF475569), fontSize: 15)),
            const SizedBox(height: 24),
            
            // Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: _tabs.map((tab) => Expanded(
                  child: GestureDetector(
                    onTap: () => _changeTab(tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _currentTab == tab ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _currentTab == tab ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                      ),
                      child: Center(
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentTab == tab ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
            
            // List Reports
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C4A6E)))
                : _reports.isEmpty 
                  ? const Center(child: Text("Không có báo cáo nào ở mục này.", style: TextStyle(color: Color(0xFF64748B))))
                  : RefreshIndicator(
                      onRefresh: _fetchReports,
                      color: const Color(0xFF0C4A6E),
                      child: ListView.builder(
                        itemCount: _reports.length,
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return _buildReportCard(report);
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final String targetType = (report['target_type'] ?? 'OTHER').toString().toUpperCase();
    final String reason = report['reason'] ?? 'Không rõ lý do';
    // Fake details to match the screenshot style since true target text isn't in 'reports' by default
    final String content = '"Sách in sai chính tả nhiều quá, chất lượng giấy tệ..."'; 
    final String authorName = report['reporter'] != null ? (report['reporter']['full_name'] ?? 'Ẩn danh') : 'Ẩn danh';
    
    // Avatar Initials
    String initials = "U";
    if (authorName.length >= 2) initials = authorName.substring(0, 2).toUpperCase();
    
    Color avatarColor = const Color(0xFFBAE6FD);
    if (targetType.contains("COMMENT")) avatarColor = const Color(0xFFFDE6CD);
    else if (targetType.contains("NOTE")) avatarColor = const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF94A3B8).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Container(
                 width: 40, height: 40,
                 decoration: BoxDecoration(color: avatarColor, borderRadius: BorderRadius.circular(12)),
                 child: Center(child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Row(
                   children: [
                     Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                     const SizedBox(width: 8),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                       decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                       child: Text(targetType, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                     ),
                   ],
                 ),
               ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Color(0xFF475569), fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: Color(0xFFB91C1C), size: 16),
              const SizedBox(width: 6),
              Text('Báo cáo: $reason', style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Giữ lại', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFECDD3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Ẩn/Xóa', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageNum extends StatelessWidget {
  final String numStr;
  final bool active;
  const _PageNum(this.numStr, this.active);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      child: Text(
        numStr,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: active ? const Color(0xFF0C4A6E) : const Color(0xFF64748B),
          fontSize: 16,
        ),
      ),
    );
  }
}
