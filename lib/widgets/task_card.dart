import 'package:flutter/material.dart';
import '../models/task.dart';
import '../screens/timer_screen.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(
          'Durée : ${task.duration.inHours}h ${task.duration.inMinutes.remainder(60)}min',
        ),
        trailing: Icon(
          task.isDone ? Icons.check_circle : Icons.play_circle,
          color: task.isDone ? Colors.green : Colors.teal,
        ),
        onTap: () {
          if (!task.isDone) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TimerScreen(task: task),
            ));
          }
        },
      ),
    );
  }
}
