import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../utils/notification_helper.dart';

class TimerScreen extends StatefulWidget {
  final Task task;

  const TimerScreen({super.key, required this.task});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late int totalSeconds;
  late int remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    totalSeconds = widget.task.duration.inSeconds;
    remainingSeconds = totalSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds == 0) {
        _timer?.cancel();
        _completeTask();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  void _completeTask() async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final updated = Task(
      id: widget.task.id,
      title: widget.task.title,
      duration: widget.task.duration,
      type: widget.task.type,
      date: widget.task.date,
      startDate: widget.task.startDate,
      endDate: widget.task.endDate,
      isDone: true,
    );
    await provider.updateTask(updated);

    // Joue une alerte sonore ou visuelle (à ajouter plus tard)
    if (context.mounted) {
      await showDoneNotification(widget.task.title);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Tâche terminée 🎉'),
          content: const Text('Le temps est écoulé.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final percent = remainingSeconds / totalSeconds;

    return Scaffold(
      appBar: AppBar(title: const Text('Minuteur')),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            Text(
              _formatTime(remainingSeconds),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
