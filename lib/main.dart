import 'package:chrono_zen/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'services/task_provider.dart';
import 'services/task_database.dart';
import 'models/task.dart';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}


// Instance globale pour les notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Douala'));

  await AndroidAlarmManager.initialize();
  await initNotifications();

  await requestPermissions();

  runApp(const ChronoZenApp());

  await AndroidAlarmManager.periodic(
    const Duration(hours: 24),
    0,
    resetDailyTasks,
    startAt: DateTime.now().add(
      Duration(
        hours: 24 - DateTime.now().hour,
        minutes: -DateTime.now().minute,
        seconds: -DateTime.now().second,
      ),
    ),
    exact: true,
    wakeup: true,
  );
}


class ChronoZenApp extends StatelessWidget {
  const ChronoZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..loadTasks(),
      child: MaterialApp(
        title: 'ChronoZen',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const MainScreen(),
      ),
    );
  }
}

// Fonction appelée automatiquement à minuit
Future<void> resetDailyTasks() async {
  final db = TaskDatabase.instance;
  final tasks = await db.fetchAllTasks();

  for (final task in tasks) {
    if (task.isDone) {
      final updated = Task(
        id: task.id,
        title: task.title,
        duration: task.duration,
        type: task.type,
        date: task.date,
        startDate: task.startDate,
        endDate: task.endDate,
        isDone: false,
      );
      await db.updateTask(updated);
    }
  }
}

// Initialisation des notifications
Future<void> initNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();

  const initSettings = InitializationSettings(
    android: android,
    iOS: ios,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}
