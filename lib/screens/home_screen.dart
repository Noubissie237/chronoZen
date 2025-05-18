import 'package:chrono_zen/screens/statistics_screen.dart';
import 'package:chrono_zen/screens/task_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_provider.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.todayTasks;

    // Durée totale des tâches
    final totalDuration = tasks.fold<Duration>(
      Duration.zero,
      (sum, task) => sum + task.duration,
    );

    // Plage active par défaut : 5h à 23h → 18h disponibles
    final totalAvailable = const Duration(hours: 18);
    final freeTime = totalAvailable - totalDuration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChronoZen'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🧘 Résumé du jour',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: const Text('Temps planifié'),
                      subtitle: Text(formatDuration(totalDuration)),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: const Text('Temps libre'),
                      subtitle: Text(formatDuration(freeTime)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '📋 Tâches du jour',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  tasks.isEmpty
                      ? const Center(
                        child: Text('Aucune tâche pour aujourd’hui'),
                      )
                      : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(task: task);
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TaskForm()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
