import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _notifications.initialize(settings);
  }

  static Future<void> scheduleTaskReminder(String title, DateTime dateTime, int id) async {
    await _notifications.zonedSchedule(
      id,
      "Task Reminder",
      title,
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(android: AndroidNotificationDetails('task_channel', 'Task Reminders')),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
