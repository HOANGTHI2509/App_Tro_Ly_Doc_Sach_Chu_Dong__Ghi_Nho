import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleDailyNotification(String timeStr) async {
    // timeStr format: "08:00 AM"
    try {
      final DateFormat format = DateFormat("hh:mm a");
      final DateTime dateTime = format.parse(timeStr);

      await _notificationsPlugin.cancelAll(); // Clear previous schedules

      await _notificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Trạm Đọc - Giờ ôn tập đến rồi!',
        body: 'Đã đến lúc củng cố kiến thức rồi bạn ơi, vào Terra ngay nhé!',
        scheduledDate: _nextInstanceOfTime(dateTime.hour, dateTime.minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_review_channel',
            'Daily Review Reminders',
            channelDescription: 'Notifications for daily card review',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Scheduled notification for $timeStr');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
