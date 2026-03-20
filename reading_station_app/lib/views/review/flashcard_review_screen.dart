import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/flashcard.dart';
import '../../providers/flashcard_provider.dart';

class FlashcardReviewScreen extends ConsumerStatefulWidget {
  const FlashcardReviewScreen({super.key});

  @override
  ConsumerState<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  int _reviewedCount = 0;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _answerCard(List<Flashcard> cards, int quality) {
    final card = cards[_currentIndex];
    ref.read(flashcardControllerProvider.notifier).reviewFlashcard(card, quality);

    setState(() {
      _reviewedCount++;
      _isFlipped = false;
    });
    _flipController.reset();

    if (_currentIndex < cards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, color: Color(0xFFFA6400), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Hoàn thành! 🎉',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn đã ôn tập $_reviewedCount thẻ',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kiến thức đang được củng cố!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFA6400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Quay lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dueAsync = ref.watch(dueFlashcardsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ôn tập',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: dueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFA6400))),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green[400], size: 80),
                  const SizedBox(height: 16),
                  const Text('Không có thẻ nào cần ôn!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Quay lại sau nhé 😊', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }

          if (_currentIndex >= cards.length) {
            _currentIndex = cards.length - 1;
          }

          final card = cards[_currentIndex];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Progress
                Row(
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${cards.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / cards.length,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation(Color(0xFFFA6400)),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Flashcard with flip animation
                Expanded(
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        final angle = _flipAnimation.value * pi;
                        final isFront = angle < pi / 2;

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: isFront
                              ? _buildCardSide(
                                  card.front,
                                  'MẶT TRƯỚC',
                                  const Color(0xFFFA6400),
                                  Icons.help_outline,
                                )
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildCardSide(
                                    card.back,
                                    'MẶT SAU',
                                    const Color(0xFF4CAF50),
                                    Icons.lightbulb_outline,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (!_isFlipped)
                  Text(
                    'Nhấn vào thẻ để xem đáp án',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  )
                else ...[
                  const Text(
                    'Bạn nhớ tốt không?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnswerButton(
                          'Quên',
                          Colors.red,
                          Icons.close,
                          () => _answerCard(cards, 1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildAnswerButton(
                          'Khó',
                          Colors.orange,
                          Icons.sentiment_dissatisfied,
                          () => _answerCard(cards, 3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildAnswerButton(
                          'Tốt',
                          Colors.blue,
                          Icons.sentiment_satisfied,
                          () => _answerCard(cards, 4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildAnswerButton(
                          'Dễ',
                          Colors.green,
                          Icons.check_circle_outline,
                          () => _answerCard(cards, 5),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardSide(String text, String label, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Spacer(),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.5),
          ),
          const Spacer(),
          Icon(Icons.touch_app, color: Colors.grey[300], size: 32),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
