import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../../models/user_book.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/note_provider.dart';
import '../notes/book_notes_screen.dart';

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
  double _sliderValue = 0.0;

  final Color _primaryGreen = const Color(0xFF568164);

  @override
  void initState() {
    super.initState();
    _currentBook = widget.userBook;
    _notesController = TextEditingController(text: _currentBook.notes);
    _progressController = TextEditingController(text: _currentBook.readingProgress.toString());
    _sliderValue = _currentBook.readingProgress.toDouble();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    
    int newProgress = int.tryParse(_progressController.text) ?? _currentBook.readingProgress;
    final int maxPages = _currentBook.book.totalPages ?? 9999;
    if (newProgress > maxPages) newProgress = maxPages;
    if (newProgress < 0) newProgress = 0;

    BookStatus newStatus = _currentBook.status;
    DateTime? newCompletedDate = _currentBook.dateCompleted;
    
    if (newProgress == maxPages && newProgress > 0 && newStatus != BookStatus.completed) {
      newStatus = BookStatus.completed;
      newCompletedDate = DateTime.now();
    }

    if (newStatus != BookStatus.completed) {
      newCompletedDate = null;
    }

    final updatedBook = _currentBook.copyWith(
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      readingProgress: newProgress,
      status: newStatus,
      dateCompleted: newCompletedDate,
      clearDateCompleted: newStatus != BookStatus.completed,
    );

    try {
      await ref.read(libraryControllerProvider.notifier).updateBook(updatedBook);
      if (mounted) {
        setState(() {
          _currentBook = updatedBook;
          _progressController.text = newProgress.toString();
          _sliderValue = newProgress.toDouble();
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Đã cập nhật ghi chú!'),
            backgroundColor: _primaryGreen,
        ));
        Navigator.pop(context);
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

      final String fileName = '${_currentBook.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await Supabase.instance.client.storage
          .from('covers')
          .upload(fileName, File(image.path));
          
      final String downloadUrl = Supabase.instance.client.storage
          .from('covers')
          .getPublicUrl(fileName);

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
      if (_currentBook.book.totalPages != null) {
         _progressController.text = _currentBook.book.totalPages.toString();
         _sliderValue = _currentBook.book.totalPages!.toDouble();
      }
    } else if (status == BookStatus.reading && _currentBook.status == BookStatus.completed) {
      completedDate = null;
    }

    setState(() {
      _currentBook = _currentBook.copyWith(status: status, dateCompleted: completedDate);
    });
  }

  void _showQuickNoteBottomSheet() {
    final noteController = TextEditingController();
    List<String> selectedTags = [];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final notesAsync = ref.read(allNotesProvider);
            final List<String> availableTags = notesAsync.when(
              data: (notes) {
                final tags = notes.expand((n) => n.tags ?? <String>[]).toSet().toList();
                return tags.isEmpty ? ['#tamlyhoc', '#thoi_quen', '#trichdan', '#kienthuc'] : tags;
              },
              loading: () => ['#tamlyhoc', '#thoi_quen', '#trichdan', '#kienthuc'],
              error: (_,__) => ['#tamlyhoc', '#thoi_quen', '#trichdan', '#kienthuc'],
            );
            final displayTags = {...availableTags, ...selectedTags}.toList();

            void toggleTag(String tag) {
              setModalState(() {
                if (selectedTags.contains(tag)) {
                  selectedTags.remove(tag);
                } else {
                  selectedTags.add(tag);
                }
              });
            }

            void showAddTagDialog() {
              final TextEditingController tagController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Thêm Nhãn Mới', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: TextField(
                    controller: tagController,
                    decoration: const InputDecoration(hintText: 'Nhập tên nhãn (vd: #quan-trong)'),
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
                    TextButton(
                      onPressed: () {
                        final newTag = tagController.text.trim();
                        if (newTag.isNotEmpty) {
                          final formattedTag = newTag.startsWith('#') ? newTag : '#$newTag';
                          if (!selectedTags.contains(formattedTag)) {
                            setModalState(() => selectedTags.add(formattedTag));
                          }
                        }
                        Navigator.pop(context);
                      },
                      child: Text('Thêm', style: TextStyle(fontWeight: FontWeight.bold, color: _primaryGreen)),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thêm ghi chú nhanh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryGreen)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    maxLines: 4,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung ghi chú...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('GỢI Ý:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                         ...displayTags.map((tag) {
                           final isSelected = selectedTags.contains(tag);
                           return Padding(
                             padding: const EdgeInsets.only(right: 8), 
                             child: InkWell(
                               onTap: () => toggleTag(tag),
                               borderRadius: BorderRadius.circular(20),
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                 decoration: BoxDecoration(
                                   color: isSelected ? _primaryGreen : const Color(0xFFEFECE5).withOpacity(0.7),
                                   borderRadius: BorderRadius.circular(20),
                                 ),
                                 child: Text(
                                   tag, 
                                   style: TextStyle(
                                     color: isSelected ? Colors.white : Colors.grey, 
                                     fontSize: 13,
                                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                   )
                                 ),
                               ),
                             )
                           );
                         }),
                         IconButton(
                           icon: Icon(Icons.add_circle, color: _primaryGreen, size: 28),
                           onPressed: showAddTagDialog,
                           padding: EdgeInsets.zero,
                           constraints: const BoxConstraints(),
                         ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (noteController.text.trim().isNotEmpty) {
                          await ref.read(noteControllerProvider.notifier).addNote(
                            _currentBook.id, 
                            noteController.text.trim(),
                            pageNumber: int.tryParse(_progressController.text),
                            tags: selectedTags.isEmpty ? null : selectedTags,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm ghi chú!')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Lưu ghi chú', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = _currentBook.book.totalPages ?? 100;
    double maxSliderVal = totalPages.toDouble();
    if (_sliderValue > maxSliderVal) _sliderValue = maxSliderVal;
    
    int currentPercentage = 0;
    if (totalPages > 0) {
      int prog = int.tryParse(_progressController.text) ?? 0;
      currentPercentage = ((prog / totalPages) * 100).round();
      if (currentPercentage > 100) currentPercentage = 100;
      if (currentPercentage < 0) currentPercentage = 0;
    }

    final notesAsyncValue = ref.watch(bookNotesProvider(_currentBook.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), // Bám sát màu kem nhạt của ảnh mẫu
      appBar: AppBar(
        title: Text(
          'Cập nhật Tiến độ', 
          style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _showDeleteConfirm,
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100), // padding dưới lớn để nhường chỗ cho nút Lưu
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thẻ Thông tin sách
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2EFEB), // Nền hơi sậm hơn một xíu tạo độ nổi
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                       GestureDetector(
                        onTap: _isUploadingImage ? null : _pickAndUploadImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(4, 4))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _currentBook.displayImageUrl.isNotEmpty
                                  ? Image.network(_currentBook.displayImageUrl, width: 85, height: 125, fit: BoxFit.cover, errorBuilder: (_,__,___) => _defaultCover())
                                  : _defaultCover(),
                              ),
                            ),
                            if (_isUploadingImage)
                              const CircularProgressIndicator(color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_currentBook.book.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2C3E35), fontFamily: 'Serif')),
                            const SizedBox(height: 6),
                            Text(_currentBook.book.author, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[500]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text('Bắt đầu: ${_formatDate(_currentBook.dateAdded)}', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                                ),
                              ],
                            )
                          ],
                        )
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Trạng thái đọc
                const Text('TRẠNG THÁI ĐỌC', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip(BookStatus.wishlist, 'Muốn đọc'),
                    const SizedBox(width: 12),
                    _buildStatusChip(BookStatus.reading, 'Đang đọc'),
                    const SizedBox(width: 12),
                    _buildStatusChip(BookStatus.completed, 'Đã xong'),
                  ],
                ),
                const SizedBox(height: 24),

                // 5-Star Rating if Completed
                if (_currentBook.status == BookStatus.completed) ...[
                  const Text('ĐÁNH GIÁ CỦA BẠN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  _buildRatingStars(),
                  const SizedBox(height: 24),
                ],

                // Tiến độ Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2EFEB),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TIẾN ĐỘ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 80,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5DFD5), // Nền hơi xỉn của progress input
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _progressController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryGreen),
                              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                              onChanged: (val) {
                                 double newVal = double.tryParse(val) ?? 0.0;
                                 if (newVal > maxSliderVal) newVal = maxSliderVal;
                                 setState(() {
                                   _sliderValue = newVal;
                                 });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text('/ ${_currentBook.book.totalPages ?? '?'} trang', style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          const Spacer(),
                          Text('$currentPercentage%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _primaryGreen)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _primaryGreen,
                          inactiveTrackColor: const Color(0xFFE5DFD5),
                          thumbColor: _primaryGreen,
                          overlayColor: _primaryGreen.withOpacity(0.2),
                          trackHeight: 8,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0, pressedElevation: 8.0),
                        ),
                        child: Slider(
                          value: _sliderValue,
                          min: 0,
                          max: maxSliderVal,
                          onChanged: (val) {
                            setState(() {
                              _sliderValue = val;
                              _progressController.text = val.toInt().toString();
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          Text('${_currentBook.book.totalPages ?? '?'} trang', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Nút Ghi chú nhanh
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F2), // Cam cực nhạt
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _primaryGreen.withOpacity(0.2), width: 1), // Changed from _primaryGreen
                  ),
                  child: InkWell(
                    onTap: _showQuickNoteBottomSheet,
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note_rounded, color: _primaryGreen, size: 24),
                        const SizedBox(width: 10),
                        Text('Ghi chú nhanh', style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Vị trí sách / Ghi chú chung
                const Text('VỊ TRÍ SÁCH / GHI CHÚ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'VD: Tủ sách phòng khách, Đang cho mượn tại thư viện...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                    filled: true,
                    fillColor: const Color(0xFFEFECE5), // Màu nền giống ảnh
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),

                // Ghi chú gần đây (Real ones)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GHI CHÚ GẦN ĐÂY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                    InkWell(
                      onTap: () {
                         Navigator.of(context).push(
                           MaterialPageRoute(builder: (context) => BookNotesScreen(userBook: _currentBook)),
                         );
                      },
                      child: Text('Xem tất cả', style: TextStyle(fontSize: 13, color: _primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                notesAsyncValue.when(
                  data: (notes) {
                    if (notes.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text('Chưa có ghi chú nào.', style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic))),
                      );
                    }
                    final recentNotes = notes.take(3).toList();
                    return Column(
                      children: recentNotes.map((note) => _buildRealNoteCard(note)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Lỗi tải ghi chú', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Nút Lưu thay đổi neo dưới cùng
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF9F6F0).withOpacity(0.0),
                    const Color(0xFFF9F6F0),
                    const Color(0xFFF9F6F0),
                  ],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          )
        ],
      )
    );
  }

  Widget _buildStatusChip(BookStatus status, String label) {
    bool isSelected = _currentBook.status == status;
    return Expanded(
      child: InkWell(
        onTap: () => _changeStatus(status),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? _primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isSelected ? _primaryGreen : Colors.grey[400]!),
          ),
          child: Center(
            child: Text(
              label, 
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    int currentRating = _currentBook.userRating ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: _primaryGreen,
            size: 36,
          ),
          onPressed: () {
            setState(() {
              _currentBook = _currentBook.copyWith(userRating: index + 1);
            });
          },
        );
      }),
    );
  }

  Widget _buildRealNoteCard(dynamic note) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFF6F0), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  note.pageNumber != null ? 'TRANG ${note.pageNumber}' : 'CHUNG', 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _primaryGreen)
                ),
              ),
              const SizedBox(width: 8),
              Text(_formatDate(note.createdAt), style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 12),
          Text(note.content, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }

  Widget _defaultCover() {
    return Container(
      width: 85, height: 125, color: Colors.grey[300],
      child: Icon(Icons.menu_book, size: 30, color: Colors.grey[500])
    );
  }
  
  String _formatDate(DateTime date) {
    List<String> months = ["Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6", "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sách'),
        content: const Text('Bạn có chắc chắn muốn xóa cuốn sách này khỏi thư viện? Mọi dữ liệu ghi chú và tiến độ sẽ bị mất.'),
        actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy', style: TextStyle(color: Colors.grey[600]))),
           TextButton(
             onPressed: () {
               ref.read(libraryControllerProvider.notifier).removeBook(_currentBook.id);
               Navigator.pop(context); 
               Navigator.pop(context); 
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa sách')));
             }, 
             child: const Text('Xóa', style: TextStyle(color: Colors.red))
           ),
        ],
      )
    );
  }
}
