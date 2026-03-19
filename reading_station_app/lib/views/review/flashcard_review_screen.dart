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

  final Color _primaryGreen = const Color(0xFF568164);
  final Color _bgColor = const Color(0xFFF9F7F2); // Màu nền kem nhạt của ảnh

  @override
  void initState() {
    super.initState();
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
    await ref.read(reviewNotifierProvider.notifier).reviewCard(note, quality);

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
                      _buildRatingButton('Rất khó', '😫', 0),
                      _buildRatingButton('Khó', '😕', 2),
                      _buildRatingButton('Dễ', '😊', 4),
                      _buildRatingButton('Rất dễ', '😁', 5),
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

  Widget _buildRatingButton(String label, String emoji, int quality) {
    bool enabled = _isFlipped;
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishScreen() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: _primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.celebration_rounded, size: 80, color: _primaryGreen),
              ),
              const SizedBox(height: 32),
              const Text(
                'Xuất sắc!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bạn đã hoàn thành tất cả các thẻ của ngày hôm nay. Kiến thức đang dần được khắc sâu!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Quay lại Trạm Đọc',
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
}
