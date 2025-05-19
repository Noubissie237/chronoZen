import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../utils/notification_helper.dart';

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isRunning = false;
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isPaused = false;

  void _startTimer({bool resume = false}) {
    if (!resume) {
      _totalSeconds = widget.task.duration.inSeconds;
      _remainingSeconds = _totalSeconds;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() => _isRunning = false);

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
        await showDoneNotification(widget.task.title);
      } else {
        setState(() => _remainingSeconds--);
      }
    });

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
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
    final isDone = widget.task.isDone;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(widget.task.title),
              subtitle: Text(
                'Durée : ${widget.task.duration.inHours}h ${widget.task.duration.inMinutes % 60}min',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('Supprimer la tâche'),
                            content: const Text(
                              'Voulez-vous vraiment supprimer cette tâche ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                    );
                    if (confirmed == true) {
                      Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).deleteTask(widget.task.id);
                    }
                  }
                  if (value == 'edit') {
                    // Naviguer vers TaskForm (à adapter si nécessaire)
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Modifier'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Supprimer'),
                      ),
                    ],
              ),
              onTap: () {
                if (!isDone && !_isRunning) _startTimer();
              },
            ),
            if (_isRunning)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: CircularProgressIndicator(
                            value: _remainingSeconds / _totalSeconds,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_isPaused) {
                            _startTimer(resume: true);
                          } else {
                            _timer?.cancel();
                            setState(() => _isPaused = true);
                          }
                        },
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(_isPaused ? 'Reprendre' : 'Pause'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          _timer?.cancel();
                          setState(() {
                            _isRunning = false;
                            _isPaused = false;
                          });
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Arrêter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            if (isDone && !_isRunning)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      "Tâche accomplie",
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
