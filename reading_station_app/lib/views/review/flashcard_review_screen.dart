import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note.dart';
import '../../providers/review_provider.dart';

class FlashcardReviewScreen extends ConsumerStatefulWidget {
  final List<Note> notes;
  const FlashcardReviewScreen({super.key, required this.notes});

  @override
  ConsumerState<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isFinished = false;
  DateTime? _startTime;

  final Color _primaryGreen = const Color(0xFF568164);
  final Color _bgColor = const Color(0xFFF9F7F2); // Màu nền kem nhạt của ảnh

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Future<void> _answer(int quality) async {
    if (!_isFlipped) return; // Chỉ cho phép đánh giá sau khi đã lật thẻ

    final note = widget.notes[_currentIndex];
    final newInterval = await ref.read(reviewNotifierProvider.notifier).reviewCard(note, quality);

    if (mounted) {
      String message = '';
      if (quality <= 2) {
         message = 'Cố gắng lên! Chúng ta sẽ ôn thẻ này vào ngày mai.';
      } else if (quality == 3) {
         message = 'Rất tốt! Bạn sẽ gặp lại thẻ này sau $newInterval ngày.';
      } else if (quality == 4) {
         message = 'Tuyệt vời! Bạn sẽ gặp lại thẻ này sau $newInterval ngày.';
      } else {
         message = 'Xuất sắc! Hẹn gặp lại thẻ này sau $newInterval ngày.';
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: _primaryGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    if (_currentIndex < widget.notes.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _controller.reset();
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildFinishScreen();
    }

    final currentNote = widget.notes[_currentIndex];
    final int total = widget.notes.length;
    final int currentNum = _currentIndex + 1;
    final double progress = currentNum / total;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trạm Đọc',
          style: TextStyle(
            color: Color(0xFF568164),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Serif',
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 20),
            child: Text(
              'Flashcards',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  // Progress Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiến độ hôm nay',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$currentNum/$total',
                              style: TextStyle(color: _primaryGreen, fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            TextSpan(
                              text: ' thẻ',
                              style: TextStyle(color: _primaryGreen, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E2D9),
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Flashcard
                  SizedBox(
                    height: constraints.maxHeight * 0.45, // Cố định chiều cao card (~45% màn hình)
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final angle = _animation.value * pi;
                          final isBack = angle > pi / 2;
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            alignment: Alignment.center,
                            child: isBack
                                ? Transform(
                                    transform: Matrix4.identity()..rotateY(pi),
                                    alignment: Alignment.center,
                                    child: _buildCardBack(currentNote),
                                  )
                                : _buildCardFront(currentNote),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Flip Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _flipCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 4,
                        shadowColor: _primaryGreen.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sync_rounded, color: Colors.white.withOpacity(0.9), size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Lật thẻ',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rating Buttons Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildRatingButton('Rất khó', '😫', 0, currentNote),
                        _buildRatingButton('Khó', '😕', 3, currentNote),
                        _buildRatingButton('Dễ', '😊', 4, currentNote),
                        _buildRatingButton('Rất dễ', '😁', 5, currentNote),
                      ],
                    ),
                  const SizedBox(height: 24),
                  
                  // Footer
                  Text(
                    'TERRA PREMIUM V2 • FOCUSED REVIEW',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(Note note) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFC59A7F).withOpacity(0.8),
            const Color(0xFFF2D1B3).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Icon(Icons.menu_book_rounded, color: Colors.white38, size: 36),
          ),
          const Spacer(),
          Text(
            'CÂU HỎI',
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            (note.question != null && note.question!.isNotEmpty) 
                ? note.question! 
                : (note.content.isNotEmpty ? note.content : 'Ghi chú trống'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontFamily: 'Serif',
              color: Color(0xFF2C3E35),
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.black.withOpacity(0.4), size: 16),
              const SizedBox(width: 8),
              Text(
                'Nhấn để xem gợi ý',
                style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Note note) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(
            'CÂU TRẢ LỜI',
            style: TextStyle(
              color: _primaryGreen.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                note.content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.6,
                  color: Color(0xFF2C3E35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (note.imageUrl != null && note.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(note.imageUrl!, height: 150, fit: BoxFit.cover),
            ),
        ],
      ),
    );
  }

  int _simulateInterval(Note note, int q) {
    if (q < 3) return 1;
    double newEaseFactor = note.easeFactor;
    int newInterval = note.interval;
    int newRepetitionCount = note.repetitionCount;

    if (newRepetitionCount == 0) {
       if (q == 3) return 2;
       if (q == 4) return 3;
       return 5;
    } else if (newRepetitionCount == 1) {
       if (q == 3) return 4;
       if (q == 4) return 6;
       return 8;
    } else {
       if (q == 3) newInterval = (newInterval * newEaseFactor * 0.8).round();
       else if (q == 4) newInterval = (newInterval * newEaseFactor).round();
       else newInterval = (newInterval * newEaseFactor * 1.3).round();
    }
    
    if (newInterval <= note.interval) {
       newInterval = note.interval + 1;
    }
    return newInterval;
  }

  Widget _buildRatingButton(String label, String emoji, int quality, Note note) {
    bool enabled = _isFlipped;
    final simulatedInterval = _simulateInterval(note, quality);

    return InkWell(
      onTap: enabled ? () => _answer(quality) : null,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2EFEB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$simulatedInterval ngày',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishScreen() {
    final streakAsync = ref.watch(streakProvider);
    final weekDaysAsync = ref.watch(weeklyStudyDaysProvider);
    final int cardsReviewed = widget.notes.length;
    final int studyMinutes = max(1, DateTime.now().difference(_startTime!).inMinutes);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF568164)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daily Goal Met',
          style: TextStyle(color: Color(0xFF568164), fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Serif'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.celebration_rounded, size: 40, color: _primaryGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chúc mừng bạn!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Serif',
                  color: Color(0xFF2C3E35),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bạn đã hoàn thành tất cả nhiệm vụ ôn tập\nhôm nay.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Streak section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EFEB),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        streakAsync.when(
                          data: (streak) => Text(
                            '$streak NGÀY LIÊN TIẾP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                          loading: () => const Text('ĐANG TẢI...'),
                          error: (_, __) => const Text('LỖI'),
                        ),
                        const Text(
                          'Tuần này',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    weekDaysAsync.when(
                      data: (weekDays) {
                        final now = DateTime.now();
                        final currentWeekday = now.weekday; // 1 to 7

                        // Cập nhật chắc chắn hôm nay là true vì người dùng vừa hoàn thành
                        List<bool> updatedWeekDays = List.from(weekDays);
                        updatedWeekDays[currentWeekday - 1] = true;

                        List<Widget> dayWidgets = [];
                        final labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                        
                        for (int i = 0; i < 7; i++) {
                          bool isToday = (i + 1) == currentWeekday;
                          dayWidgets.add(
                            _buildDayItem(isToday ? 'HÔM NAY' : labels[i], updatedWeekDays[i], isToday)
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: dayWidgets,
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Lỗi tải dữ liệu tuần'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats Row: Thẻ đã ôn and Phút học
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.style, color: Colors.orange[800], size: 24),
                          const SizedBox(height: 12),
                          Text(
                            '$cardsReviewed',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E35)),
                          ),
                          const SizedBox(height: 4),
                          const Text('thẻ đã ôn', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.access_time_filled, color: _primaryGreen, size: 24),
                          const SizedBox(height: 12),
                          Text(
                            '$studyMinutes',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E35)),
                          ),
                          const SizedBox(height: 4),
                          const Text('phút học', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Nút về trang chủ
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Quay lại',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayItem(String defaultLabel, bool isActive, bool forceHighlight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: forceHighlight ? 50 : 36,
              height: forceHighlight ? 50 : 36,
              decoration: BoxDecoration(
                color: forceHighlight ? const Color(0xFFEBEFEB) : Colors.transparent, 
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department,
                color: isActive ? _primaryGreen : Colors.grey[350],
                size: forceHighlight ? 30 : 22,
              ),
            ),
            if (isActive)
              Positioned(
                top: forceHighlight ? -6 : -4,
                right: forceHighlight ? -2 : -6,
                child: Container(
                  width: 14,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: forceHighlight ? _primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: forceHighlight ? [] : [
                       BoxShadow(
                         color: Colors.black.withOpacity(0.05),
                         blurRadius: 4,
                       )
                    ],
                  ),
                  child: Icon(
                    Icons.check, 
                    color: forceHighlight ? Colors.white : _primaryGreen, 
                    size: 10,
                    weight: 900,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          defaultLabel,
          style: TextStyle(
            fontSize: 10,
            fontWeight: forceHighlight ? FontWeight.bold : FontWeight.w600,
            color: forceHighlight ? _primaryGreen : Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
