import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBooksScreen extends StatefulWidget {
  const AdminBooksScreen({super.key});

  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _books = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('books')
          .select()
          .order('created_at', ascending: false)
          .limit(50); // Get latest 50 for admin preview
      setState(() {
        _books = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: \$e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBook(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa cuốn sách gốc này khỏi CSDL?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Xóa', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.from('books').delete().eq('id', id);
        _fetchBooks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa thành công!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: \$e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Danh mục Sách', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _books.length,
            itemBuilder: (context, index) {
              final book = _books[index];
              return ListTile(
                leading: book['cover_image_url'] != null 
                  ? Image.network(book['cover_image_url'], width: 40, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.book, size: 40))
                  : const Icon(Icons.book, size: 40),
                title: Text(book['title'] ?? 'Không tên', maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('Tác giả: \${(book["authors"] as List?)?.join(", ") ?? "Chưa rõ"}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteBook(book['id']),
                ),
                onTap: () {
                  // TODO: Open Edit Dialoug
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng sửa dữ liệu đang hoàn thiện')));
                },
              );
            },
          ),
    );
  }
}
