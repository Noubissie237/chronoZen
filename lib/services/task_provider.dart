import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_database.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  final _db = TaskDatabase.instance;

  List<Task> get tasks => _tasks;

  // Récupère uniquement les tâches du jour
  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.type == TaskType.persistent) {
        return true;
      }
      if (task.type == TaskType.semiPersistent) {
        return task.startDate != null &&
            task.endDate != null &&
            now.isAfter(task.startDate!.subtract(const Duration(days: 1))) &&
            now.isBefore(task.endDate!.add(const Duration(days: 1)));
      }
      if (task.type == TaskType.nonPersistent) {
        return task.date != null &&
            task.date!.year == now.year &&
            task.date!.month == now.month &&
            task.date!.day == now.day;
      }
      return false;
    }).toList();
  }

  Future<void> loadTasks() async {
    _tasks.clear();
    _tasks.addAll(await _db.fetchAllTasks());
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _db.insertTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      await _db.updateTask(updatedTask);
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> resetDailyTasks() async {
    final today = DateTime.now();
    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.type != TaskType.nonPersistent || task.date?.isAtSameMomentAs(today) == true) {
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
        await _db.updateTask(updated);
        _tasks[i] = updated;
      }
    }
    notifyListeners();
  }

  Map<DateTime, List<Task>> getTasksGroupedByDay({int days = 7}) {
    final now = DateTime.now();
    final Map<DateTime, List<Task>> result = {};

    for (int i = 0; i < days; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));

      final tasksOfDay = _tasks.where((task) {
        if (task.type == TaskType.persistent) return true;
        if (task.type == TaskType.semiPersistent) {
          return task.startDate != null &&
                task.endDate != null &&
                !day.isBefore(task.startDate!) &&
                !day.isAfter(task.endDate!);
        }
        if (task.type == TaskType.nonPersistent) {
          return task.date != null &&
              task.date!.year == day.year &&
              task.date!.month == day.month &&
              task.date!.day == day.day;
        }
        return false;
      }).toList();

      result[day] = tasksOfDay;
    }

    return result;
  }

}
