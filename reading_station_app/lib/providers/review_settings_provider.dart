import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';

class ReviewSettings {
  final int dailyGoal;
  final String notificationTime;
  final bool isSpacedRepetitionOn;
  final int difficultyLevel; // 0: DỄ, 1: TRUNG BÌNH, 2: KHÓ

  ReviewSettings({
    this.dailyGoal = 10,
    this.notificationTime = '08:00 AM',
    this.isSpacedRepetitionOn = true,
    this.difficultyLevel = 1,
  });

  ReviewSettings copyWith({
    int? dailyGoal,
    String? notificationTime,
    bool? isSpacedRepetitionOn,
    int? difficultyLevel,
  }) {
    return ReviewSettings(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      notificationTime: notificationTime ?? this.notificationTime,
      isSpacedRepetitionOn: isSpacedRepetitionOn ?? this.isSpacedRepetitionOn,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }
  factory ReviewSettings.fromMap(Map<String, dynamic> map) {
    return ReviewSettings(
      dailyGoal: map['daily_goal'] ?? 10,
      notificationTime: map['notification_time'] ?? '08:00 AM',
      isSpacedRepetitionOn: map['is_spaced_repetition_on'] ?? true,
      difficultyLevel: map['difficulty_level'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'daily_goal': dailyGoal,
      'notification_time': notificationTime,
      'is_spaced_repetition_on': isSpacedRepetitionOn,
      'difficulty_level': difficultyLevel,
    };
  }
}


class ReviewSettingsNotifier extends AsyncNotifier<ReviewSettings> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<ReviewSettings> build() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return ReviewSettings();

    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        final settings = ReviewSettings.fromMap(response);
        // Schedule notification based on loaded settings
        NotificationService().scheduleDailyNotification(settings.notificationTime);
        return settings;
      } else {
        // Schedule with default time if none exists
        NotificationService().scheduleDailyNotification('08:00 AM');
        return ReviewSettings();
      }
    } catch (e) {
      print('Lỗi lấy settings: $e');
      return ReviewSettings();
    }
  }

  Future<void> _updateSupabase(ReviewSettings newSettings) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('user_settings').upsert({
        'user_id': user.id,
        ...newSettings.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Lỗi cập nhật settings: $e');
    }
  }

  Future<void> updateDailyGoal(int goal) async {
    if (state.value == null) return;
    final newSettings = state.value!.copyWith(dailyGoal: goal);
    state = AsyncData(newSettings);
    await _updateSupabase(newSettings);
  }

  Future<void> toggleSpacedRepetition(bool isOn) async {
    if (state.value == null) return;
    final newSettings = state.value!.copyWith(isSpacedRepetitionOn: isOn);
    state = AsyncData(newSettings);
    await _updateSupabase(newSettings);
  }

  Future<void> updateDifficulty(int difficulty) async {
    if (state.value == null) return;
    final newSettings = state.value!.copyWith(difficultyLevel: difficulty);
    state = AsyncData(newSettings);
    await _updateSupabase(newSettings);
  }

  Future<void> updateNotificationTime(String time) async {
    if (state.value == null) return;
    final newSettings = state.value!.copyWith(notificationTime: time);
    state = AsyncData(newSettings);
    await _updateSupabase(newSettings);
    // Update local schedule immediately
    await NotificationService().scheduleDailyNotification(time);
  }
}

final reviewSettingsProvider = AsyncNotifierProvider<ReviewSettingsNotifier, ReviewSettings>(
  ReviewSettingsNotifier.new,
);
