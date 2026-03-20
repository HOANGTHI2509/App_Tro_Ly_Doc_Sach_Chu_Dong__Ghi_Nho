import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    try {
      // Fetch reports joined with reported user data
      final data = await _supabase
          .from('reports')
          .select('*, reported_user:users!reported_user_id(name, email)')
          .order('created_at', ascending: false);
      setState(() {
        _reports = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải báo cáo: \$e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resolveReport(String id, String status) async {
    try {
      await _supabase.from('reports').update({'status': status}).eq('id', id);
      _fetchReports();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật trạng thái báo cáo')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: \$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Báo cáo', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.red[600],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _reports.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final r = _reports[index];
              final isPending = r['status'] == 'pending';
              final userName = r['reported_user']?['name'] ?? 'Người dùng Ẩn';
              
              return Card(
                elevation: 2,
                color: isPending ? Colors.red[50] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bị báo cáo: \$userName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPending ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: Text(
                              isPending ? 'CHỜ XỬ LÝ' : 'ĐÃ XỬ LÝ', 
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Lý do: \${r["reason"]}'),
                      if (r['note_id'] != null) Text('Loại vi phạm: Ghi chú (Note)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      if (r['activity_id'] != null) Text('Loại vi phạm: Bảng tin (Activity Feed)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 12),
                      if (isPending) 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _resolveReport(r['id'], 'dismissed'), 
                              child: const Text('Bỏ qua', style: TextStyle(color: Colors.grey))
                            ),
                            ElevatedButton(
                              onPressed: () => _resolveReport(r['id'], 'resolved'), 
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Xử lý / Gỡ nội dung', style: TextStyle(color: Colors.white))
                            )
                          ],
                        )
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
