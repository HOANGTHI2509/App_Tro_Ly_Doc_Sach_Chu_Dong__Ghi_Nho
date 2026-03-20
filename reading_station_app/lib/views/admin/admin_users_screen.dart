import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);
      setState(() {
        _users = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải danh sách User: \$e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAdminRole(String id, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'user' : 'admin';
    try {
      await _supabase.from('users').update({'role': newRole}).eq('id', id);
      _fetchUsers();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã đổi quyền thành \$newRole')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: \$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Người Dùng', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final u = _users[index];
              final isAdmin = u['role'] == 'admin';
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isAdmin ? Colors.red : Colors.blue,
                  child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                ),
                title: Text(u['name'] ?? 'Không tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(u['email'] ?? 'Không có email'),
                trailing: ElevatedButton(
                  onPressed: () => _toggleAdminRole(u['id'], u['role']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdmin ? Colors.grey : Colors.indigo,
                  ),
                  child: Text(isAdmin ? 'Bỏ Admin' : 'Cấp Admin', style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          ),
    );
  }
}
