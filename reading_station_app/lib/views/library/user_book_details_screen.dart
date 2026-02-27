import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../models/user_book.dart';
import '../../../providers/library_provider.dart';

class UserBookDetailsScreen extends ConsumerStatefulWidget {
  final UserBook userBook;

  const UserBookDetailsScreen({super.key, required this.userBook});

  @override
  ConsumerState<UserBookDetailsScreen> createState() => _UserBookDetailsScreenState();
}

class _UserBookDetailsScreenState extends ConsumerState<UserBookDetailsScreen> {
  late UserBook _currentBook;
  late TextEditingController _notesController;
  late TextEditingController _progressController;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.userBook;
    _notesController = TextEditingController(text: _currentBook.notes);
    _progressController = TextEditingController(text: _currentBook.readingProgress.toString());
  }

  @override
  void dispose() {
    _notesController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    
    // Parse progress safely
    int newProgress = int.tryParse(_progressController.text) ?? _currentBook.readingProgress;
    final int maxPages = _currentBook.book.totalPages ?? 9999;
    if (newProgress > maxPages) newProgress = maxPages;
    if (newProgress < 0) newProgress = 0;

    // Check if status needs to change to completed
    BookStatus newStatus = _currentBook.status;
    DateTime? newCompletedDate = _currentBook.dateCompleted;
    if (newProgress == maxPages && newStatus != BookStatus.completed) {
      newStatus = BookStatus.completed;
      newCompletedDate = DateTime.now();
    } else if (newStatus == BookStatus.wishlist && newProgress > 0) {
      newStatus = BookStatus.reading;
    }

    final updatedBook = _currentBook.copyWith(
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      readingProgress: newProgress,
      status: newStatus,
      dateCompleted: newCompletedDate,
    );

    try {
      await ref.read(libraryControllerProvider.notifier).updateBook(updatedBook);
      if (mounted) {
        setState(() {
          _currentBook = updatedBook;
          _progressController.text = newProgress.toString();
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu thay đổi thành công!')));
        Navigator.pop(context); // Auto-pop after saving
      }
    } catch (e) {
       if (mounted) {
         setState(() => _isSaving = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
       }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    
    // Show dialog to choose source
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật bìa sách'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Chụp ảnh mới'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(source: source, imageQuality: 70);
      if (image == null) return;

      setState(() => _isUploadingImage = true);

      // Upload to Firebase Storage
      final String fileName = 'covers/${_currentBook.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      final uploadTask = await storageRef.putFile(File(image.path));
      final String downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update current book silently (will be saved to DB when user presses Save)
      setState(() {
        _currentBook = _currentBook.copyWith(customCoverUrl: downloadUrl);
        _isUploadingImage = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tải ảnh lên thành công. Nhấn Lưu thay đổi để hoàn tất.')));
      }

    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải ảnh: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _changeStatus(BookStatus status) {
    if (_currentBook.status == status) return;
    
    DateTime? completedDate = _currentBook.dateCompleted;
    if (status == BookStatus.completed) {
      completedDate = DateTime.now();
      // Auto-fill progress to max if marked completed
      if (_currentBook.book.totalPages != null) {
         _progressController.text = _currentBook.book.totalPages.toString();
      }
    } else if (status == BookStatus.reading && _currentBook.status == BookStatus.completed) {
      completedDate = null; // reset completion date if move back to reading
    }

    setState(() {
      _currentBook = _currentBook.copyWith(status: status, dateCompleted: completedDate);
    });
    // Don't auto-save immediately, let user click save
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Cập nhật sách', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showDeleteConfirm,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Cover + Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _isUploadingImage ? null : _pickAndUploadImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _currentBook.displayImageUrl.isNotEmpty
                          ? Image.network(_currentBook.displayImageUrl, width: 90, height: 130, fit: BoxFit.cover, errorBuilder: (_,__,___) => _defaultCover())
                          : _defaultCover(),
                      ),
                      if (_isUploadingImage)
                        const CircularProgressIndicator(color: Colors.white),
                      if (!_isUploadingImage)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_currentBook.book.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(_currentBook.book.author, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      const SizedBox(height: 10),
                      Text('Đã thêm: ${_formatDate(_currentBook.dateAdded)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  )
                )
              ],
            ),
            const SizedBox(height: 30),

            // Target 1: Status Selection
            const Text('Trạng thái của bạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusChip(BookStatus.wishlist, 'Muốn đọc', Colors.orange),
                const SizedBox(width: 10),
                _buildStatusChip(BookStatus.reading, 'Đang đọc', Colors.blue),
                const SizedBox(width: 10),
                _buildStatusChip(BookStatus.completed, 'Đã xong', Colors.green),
              ],
            ),
            const SizedBox(height: 30),

            // Target 2: Reading Progress (FR1.3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 const Text('Tiến độ đọc (trang)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                 Text('${_currentBook.percentage}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _progressController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('/', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                     decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                     child: Text('${_currentBook.book.totalPages ?? '?'} trang', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: (_currentBook.percentage) / 100,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 30),

            // Target 3: Physical Location / Notes (FR1.2)
            const Text('Vị trí sách / Ghi chú (VD: Tủ sách, Cho mượn)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú hoặc vị trí sách vật lý...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      )
    );
  }

  Widget _buildStatusChip(BookStatus status, String label, Color baseColor) {
    bool isSelected = _currentBook.status == status;
    return Expanded(
      child: InkWell(
        onTap: () => _changeStatus(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? baseColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? baseColor : Colors.grey[300]!),
          ),
          child: Center(
            child: Text(
              label, 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[700]
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultCover() {
    return Container(
      width: 90, height: 130, color: Colors.grey[300],
      child: Icon(Icons.menu_book, size: 40, color: Colors.grey[500])
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sách'),
        content: const Text('Bạn có chắc chắn muốn xóa cuốn sách này khỏi thư viện? Mọi dữ liệu ghi chú và tiến độ sẽ bị mất.'),
        actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
           TextButton(
             onPressed: () {
               ref.read(libraryControllerProvider.notifier).removeBook(_currentBook.id);
               Navigator.pop(context); // close dialog
               Navigator.pop(context); // close screen
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa sách')));
             }, 
             child: const Text('Xóa', style: TextStyle(color: Colors.red))
           ),
        ],
      )
    );
  }
}
