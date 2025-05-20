import 'package:timezone/timezone.dart' as tz;
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

Future<void> scheduleTaskNotification({
  required String taskId,
  required String title,
  required Duration delay,
}) async {
  final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    taskId.hashCode, // ID unique
    '⏱️ Tâche terminée',
    '“$title” est arrivée à son terme.',
    scheduledTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel',
        'Notifications des tâches',
        channelDescription: 'Canal pour les alertes de fin de tâche',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('alert'),
      ),
      iOS: DarwinNotificationDetails(presentSound: true),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ obligatoire
    matchDateTimeComponents: null, // facultatif
  );
}
