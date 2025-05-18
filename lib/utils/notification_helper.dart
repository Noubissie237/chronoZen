import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

Future<void> showDoneNotification(String title) async {
  const androidDetails = AndroidNotificationDetails(
    'task_channel',
    'Tâches',
    channelDescription: 'Notification de fin de tâche',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    ticker: 'ticker',
  );

  const iosDetails = DarwinNotificationDetails();

  const notificationDetails =
      NotificationDetails(android: androidDetails, iOS: iosDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Tâche terminée',
    title,
    notificationDetails,
  );
}
