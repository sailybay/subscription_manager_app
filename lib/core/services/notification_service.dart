import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../../domain/entities/subscription.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Инициализация временных зон (нужно для планирования по времени)
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  /// Запланировать уведомление о подписке
  Future<void> scheduleSubscriptionReminder(Subscription sub) async {
    // Напоминаем за 1 день до оплаты в 10:00 утра
    final reminderDate = sub.nextBillingDate.subtract(const Duration(days: 1));
    final scheduledDate = tz.TZDateTime.from(
      DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 10, 0),
      tz.local,
    );

    // Если дата уже прошла (например, подписка завтра), не планируем или планируем на сейчас
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications.zonedSchedule(
      sub.id, // Используем ID подписки как ID уведомления
      'Напоминание об оплате',
      'Завтра спишется ${sub.price}₽ за ${sub.name}',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'billing_reminders',
          'Напоминания об оплате',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Отменить уведомление
  Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }
}
