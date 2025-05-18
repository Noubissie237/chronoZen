import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/task_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  String format(Duration d) =>
      '${d.inHours}h${(d.inMinutes % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final data = taskProvider.getTasksGroupedByDay();
    final days = data.keys.toList()..sort();

    Duration totalPlanned = Duration.zero;
    Duration totalDone = Duration.zero;

    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < days.length; i++) {
      final date = days[i];
      final tasks = data[date]!;

      final planned = tasks.fold<Duration>(
          Duration.zero, (sum, task) => sum + task.duration);
      final done = tasks
          .where((t) => t.isDone)
          .fold<Duration>(Duration.zero, (sum, task) => sum + task.duration);

      totalPlanned += planned;
      totalDone += done;

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: done.inHours + done.inMinutes % 60 / 60.0, color: Colors.blue)
        ],
      ));
    }

    final latestDay = days.isNotEmpty ? days.last : DateTime.now();
    final latestTasks = data[latestDay] ?? [];

    final completedCount = latestTasks.where((t) => t.isDone).length;
    final createdCount = latestTasks.length;

    final plannedToday = latestTasks.fold<Duration>(
        Duration.zero, (s, t) => s + t.duration);
    final doneToday = latestTasks
        .where((t) => t.isDone)
        .fold<Duration>(Duration.zero, (s, t) => s + t.duration);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('📊 Semaine en cours', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                        final day = days[value.toInt()];
                        return Text(['lun.', 'mar.', 'me.', 'jeu.', 'ven.', 'sam.', 'dim.'][day.weekday - 1]);
                      }),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '📅 ${latestDay.day}/${latestDay.month}/${latestDay.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('- $createdCount tâches créées'),
            Text('- $completedCount tâches complétées'),
            Text('- ${format(plannedToday)} prévues / ${format(doneToday)} réalisées'),
            const SizedBox(height: 24),
            const Text('🧮 7 derniers jours :', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('- ${format(totalPlanned)} planifiées'),
            Text('- ${format(totalDone)} accomplies'),
            Text('- ${(totalPlanned.inMinutes == 0) ? 0 : (100 * totalDone.inMinutes / totalPlanned.inMinutes).round()}% de complétion'),
          ],
        ),
      ),
    );
  }
}
