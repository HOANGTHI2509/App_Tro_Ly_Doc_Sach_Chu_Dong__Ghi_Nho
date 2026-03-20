import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/flashcard_provider.dart';
import 'flashcard_review_screen.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueAsync = ref.watch(dueFlashcardsProvider);
    final statsAsync = ref.watch(flashcardStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ôn tập',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.history, color: Colors.red[400]),
                ],
              ),
              
              const SizedBox(height: 20),

              // Hero Card (Daily Task)
              dueAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Lỗi: $e'),
                data: (dueCards) {
                  final count = dueCards.length;
                  final minutes = (count * 0.4).ceil(); // ~25s mỗi thẻ
                  
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7043), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nhiệm vụ hôm nay',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count > 0 ? '~$minutes phút' : 'Xong!',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          count > 0 ? '$count thẻ' : '0 thẻ',
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          count > 0
                              ? 'Kiến thức cần được "tưới nước" để xanh tốt. Sẵn sàng chưa?'
                              : 'Tuyệt vời! Bạn đã ôn tập xong hôm nay! 🎉',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: count > 0
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const FlashcardReviewScreen()),
                                  );
                                }
                              : null,
                          icon: Icon(
                            count > 0 ? Icons.play_arrow_rounded : Icons.check,
                            color: const Color(0xFFFF5722),
                          ),
                          label: Text(
                            count > 0 ? 'Bắt đầu ôn tập' : 'Đã hoàn thành',
                            style: const TextStyle(color: Color(0xFFFF5722), fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),

              // Stats Row
              statsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) {
                  return Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        '${stats['due'] ?? 0}', 'Cần ôn hôm nay',
                        const Color(0xFFFFF3E0), Icons.local_fire_department, Colors.orange,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard(
                        '${stats['mastered'] ?? 0}', 'Thẻ đã thuộc',
                        const Color(0xFFE8F5E9), Icons.check_circle_outline, Colors.green,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard(
                        '${stats['total'] ?? 0}', 'Tổng thẻ',
                        const Color(0xFFFFEBE5), Icons.layers, Colors.redAccent,
                      )),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 20),
             
              const Text('Hướng dẫn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),

              _buildTipCard(
                icon: Icons.note_add,
                title: 'Tạo Flashcard',
                description: 'Vào tab Ghi chú → chọn 1 ghi chú → nhấn "Tạo FlashCard" để bắt đầu.',
              ),
              const SizedBox(height: 10),
              _buildTipCard(
                icon: Icons.psychology,
                title: 'Thuật toán SM-2',
                description: 'Hệ thống tự động điều chỉnh lịch ôn dựa trên mức nhớ của bạn (Quên → Khó → Tốt → Dễ).',
              ),
              const SizedBox(height: 10),
              _buildTipCard(
                icon: Icons.alarm,
                title: 'Ôn tập mỗi ngày',
                description: 'Chỉ cần 2-5 phút mỗi ngày để kiến thức ăn sâu vào bộ nhớ dài hạn.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color bgColor, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTipCard({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFA6400), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
