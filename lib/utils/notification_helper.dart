import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

Future<void> showDoneNotification(String title) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'task_channel', // ID du canal
    'Notifications des tâches',
    channelDescription: 'Canal pour les alertes de fin de tâche',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    sound: RawResourceAndroidNotificationSound('alert'), // fichier mp3 dans /res
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentSound: true,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    '⏱️ Tâche terminée',
    title,
    platformDetails,
  );
}
