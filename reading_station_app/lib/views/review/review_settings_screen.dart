import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/review_provider.dart';
import '../../providers/review_settings_provider.dart';

class ReviewSettingsScreen extends ConsumerWidget {
  const ReviewSettingsScreen({super.key});

  final Color _primaryGreen = const Color(0xFF4C7053);
  final Color _bgColor = const Color(0xFFFAF7F2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(reviewSettingsProvider);
    final totalNotesCountAsync = ref.watch(totalNotesCountProvider);
    final streakAsync = ref.watch(streakProvider);

    return settingsAsync.when(
      data: (settings) => Scaffold(
        backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Cài đặt Ôn tập',
          style: TextStyle(
            color: Color(0xFF2C3E35), // Dark green-grey
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Serif',
          ),
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE6D6C3), // Light brown premium bg
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  color: Color(0xFF594A3D),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EFE9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.local_fire_department, color: Color(0xFF8B6B4A), size: 28),
                        const SizedBox(height: 8),
                        Text('Chuỗi ngày', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        const SizedBox(height: 4),
                        streakAsync.when(
                          data: (streak) => Text(
                            '$streak ngày',
                            style: TextStyle(color: _primaryGreen, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Lỗi'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3ED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.style, color: Color(0xFF568164), size: 28),
                        const SizedBox(height: 8),
                        Text('Tổng số thẻ', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        const SizedBox(height: 4),
                        totalNotesCountAsync.when(
                          data: (count) => Text(
                            '$count',
                            style: TextStyle(color: _primaryGreen, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Lỗi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mục tiêu hàng ngày
            _buildSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag, color: _primaryGreen, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        'Mục tiêu hàng ngày',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDailyGoalOption(ref, 10, settings.dailyGoal),
                      _buildDailyGoalOption(ref, 20, settings.dailyGoal),
                      _buildDailyGoalOption(ref, 50, settings.dailyGoal),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Thông báo nhắc nhở
            _buildSectionContainer(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6D6C3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active, color: Color(0xFF594A3D), size: 22),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông báo nhắc nhở',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bắt đầu ngày mới cùng Terra',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(settings.notificationTime.split(' ')[0], style: TextStyle(color: _primaryGreen, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
                      Text(settings.notificationTime.split(' ')[1], style: TextStyle(color: _primaryGreen, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
                    ],
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      // current time in settings: '08:00 AM'
                      int initialHour = 8;
                      int initialMinute = 0;
                      try {
                        final timeParts = settings.notificationTime.split(' ');
                        final hm = timeParts[0].split(':');
                        initialHour = int.parse(hm[0]);
                        initialMinute = int.parse(hm[1]);
                        if (timeParts.length > 1 && timeParts[1] == 'PM' && initialHour < 12) {
                          initialHour += 12;
                        }
                        if (timeParts.length > 1 && timeParts[1] == 'AM' && initialHour == 12) {
                          initialHour = 0;
                        }
                      } catch (_) {}

                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: _primaryGreen,
                                onPrimary: Colors.white,
                                onSurface: const Color(0xFF2C3E35),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        final hour = picked.hour;
                        final minute = picked.minute.toString().padLeft(2, '0');
                        final period = hour >= 12 ? 'PM' : 'AM';
                        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                        final formattedTime = '${displayHour.toString().padLeft(2, '0')}:$minute $period';
                        ref.read(reviewSettingsProvider.notifier).updateNotificationTime(formattedTime);
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F3ED),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit, color: _primaryGreen, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Thuật toán Spaced Repetition
            _buildSectionContainer(
              bgColor: const Color(0xFFF1F3ED), // Light green-tinted background
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Thuật toán Spaced',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Repetition',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B6B4A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('AI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tự động tối ưu hóa lịch trình ôn tập dựa trên tốc độ ghi nhớ của riêng bạn.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: settings.isSpacedRepetitionOn,
                    onChanged: (val) {
                      ref.read(reviewSettingsProvider.notifier).toggleSpacedRepetition(val);
                    },
                    activeColor: Colors.white,
                    activeTrackColor: _primaryGreen,
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Độ khó mặc định
            _buildSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: _primaryGreen, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        'Độ khó mặc định',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDifficultyOption(ref, 0, 'DỄ', settings.difficultyLevel),
                      _buildDifficultyOption(ref, 1, 'TRUNG BÌNH', settings.difficultyLevel),
                      _buildDifficultyOption(ref, 2, 'KHÓ', settings.difficultyLevel),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Custom Slider Track
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBE8E1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSliderThumb(ref, 0, settings.difficultyLevel),
                          _buildSliderThumb(ref, 1, settings.difficultyLevel),
                          _buildSliderThumb(ref, 2, settings.difficultyLevel),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Footer text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, color: Colors.grey, size: 14),
                const SizedBox(width: 6),
                Text('Terra Premium Active', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
    loading: () => Scaffold(backgroundColor: _bgColor, body: const Center(child: CircularProgressIndicator())),
    error: (e, st) => Scaffold(backgroundColor: _bgColor, body: Center(child: Text('Lỗi tải cài đặt: $e'))),
    );
  }

  Widget _buildSectionContainer({required Widget child, Color? bgColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildDailyGoalOption(WidgetRef ref, int count, int currentGoal) {
    bool isSelected = currentGoal == count;
    return GestureDetector(
      onTap: () {
        ref.read(reviewSettingsProvider.notifier).updateDailyGoal(count);
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _primaryGreen : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: _primaryGreen.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? _primaryGreen : Colors.black87,
              ),
            ),
            Text(
              'thẻ',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? _primaryGreen : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(WidgetRef ref, int index, String label, int currentDifficulty) {
    bool isSelected = currentDifficulty == index;
    return GestureDetector(
      onTap: () {
        ref.read(reviewSettingsProvider.notifier).updateDifficulty(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? _primaryGreen : Colors.grey[800],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderThumb(WidgetRef ref, int index, int currentDifficulty) {
    bool isSelected = currentDifficulty == index;
    return GestureDetector(
      onTap: () {
        ref.read(reviewSettingsProvider.notifier).updateDifficulty(index);
      },
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        color: Colors.transparent, // expand hit area
        child: Container(
          width: isSelected ? 16 : 0,
          height: isSelected ? 16 : 0,
          decoration: BoxDecoration(
            color: _primaryGreen,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
