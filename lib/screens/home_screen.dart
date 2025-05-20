import 'package:chrono_zen/models/task.dart';
import 'package:chrono_zen/screens/task_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_provider.dart';
import '../widgets/task_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  // ignore: unused_field
  late Future<Duration> _availableTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _availableTime = getAvailableTimeForToday();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}min';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String _getMotivationalQuote() {
    final quotes = [
      'Chaque minute compte !',
      'Transformez vos rêves en réalité',
      'La productivité commence maintenant',
      'Votre futur vous en sera reconnaissant',
      'Progressez un jour à la fois',
    ];
    return quotes[DateTime.now().day % quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final rawTasks = taskProvider.todayTasks;

    final tasks = List<Task>.from(rawTasks)..sort((a, b) {
      if (a.isDone == b.isDone) return 0;
      return a.isDone ? 1 : -1; // Les tâches non faites en haut
    });

    final completedTasks = rawTasks.where((task) => task.isDone).length;
    final totalTasks = rawTasks.length;

    // Durée totale des tâches
    final totalDuration = rawTasks.fold<Duration>(
      Duration.zero,
      (sum, task) => sum + task.duration,
    );

    final completedDuration = rawTasks
        .where((task) => task.isDone)
        .fold<Duration>(Duration.zero, (sum, task) => sum + task.duration);

    // Plage active par défaut : 5h à 23h → 18h disponibles
    // final freeTime = totalAvailable - totalDuration;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : Colors.grey[50],
      appBar: AppBar(
        elevation: 1,
        backgroundColor: const Color.fromARGB(0, 64, 195, 255),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset('assets/images/logo.png', width: 32, height: 32),
        ),
        title: Text(
          'ChronoZen',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: theme.primaryColor,
          ),
        ),
        centerTitle: true,
      ),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              // Simulate refresh
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section de salutation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            isDark
                                ? [
                                  theme.primaryColor.withOpacity(0.2),
                                  theme.primaryColor.withOpacity(0.1),
                                ]
                                : [
                                  theme.primaryColor.withOpacity(0.1),
                                  theme.primaryColor.withOpacity(0.05),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow:
                          isDark
                              ? null
                              : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.wb_sunny_rounded,
                                color: theme.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getGreeting()} !',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getMotivationalQuote(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Statistiques du jour
                  Text(
                    '📊 Résumé du jour',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cartes de statistiques
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          context,
                          title: 'Tâches',
                          value: '$completedTasks/$totalTasks',
                          subtitle: 'complétées',
                          icon: Icons.check_circle_rounded,
                          color: Colors.green,
                          progress:
                              totalTasks > 0
                                  ? completedTasks / totalTasks
                                  : 0.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatsCard(
                          context,
                          title: 'Temps planifié',
                          value: formatDuration(totalDuration),
                          subtitle: 'aujourd\'hui',
                          icon: Icons.schedule_rounded,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatsCard(
                          context,
                          title: 'Temps accompli',
                          value: formatDuration(completedDuration),
                          subtitle: 'terminé',
                          icon: Icons.timer_rounded,
                          color: Colors.orange,
                          progress:
                              totalDuration.inSeconds > 0
                                  ? completedDuration.inSeconds /
                                      totalDuration.inSeconds
                                  : 0.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FutureBuilder<Duration>(
                          future: getAvailableTimeForToday(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return _buildStatsCard(
                                context,
                                title: 'Temps libre',
                                value: '--',
                                subtitle: 'chargement...',
                                icon: Icons.free_breakfast_rounded,
                                color: Colors.purple,
                              );
                            }

                            final totalAvailable = snapshot.data!;
                            final freeTime = totalAvailable - totalDuration;

                            return _buildStatsCard(
                              context,
                              title: 'Temps libre',
                              value: formatDuration(freeTime),
                              subtitle: 'disponible',
                              icon: Icons.free_breakfast_rounded,
                              color: Colors.purple,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Section des tâches
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📋 Tâches du jour',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (tasks.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${tasks.length} tâche${tasks.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Liste des tâches
                  if (tasks.isEmpty)
                    _buildEmptyState(context)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutBack,
                          child: TaskCard(task: task),
                        );
                      },
                    ),

                  // Espacement pour le FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TaskForm()));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle tâche'),
        elevation: 8,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    double? progress,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isDark
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        border:
            isDark
                ? Border.all(
                  color: theme.dividerColor.withOpacity(0.1),
                  width: 1,
                )
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (progress != null)
                Container(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: progress,
                    color: color,
                    backgroundColor: color.withOpacity(0.1),
                    strokeWidth: 3,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt_rounded,
              size: 48,
              color: theme.primaryColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune tâche pour aujourd\'hui',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par ajouter votre première tâche !',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const TaskForm()));
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter une tâche'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<Duration> getAvailableTimeForToday() async {
  final prefs = await SharedPreferences.getInstance();

  final sleepStart = TimeOfDay(
    hour: prefs.getInt('sleep_start_hour') ?? 23,
    minute: prefs.getInt('sleep_start_minute') ?? 0,
  );
  final sleepEnd = TimeOfDay(
    hour: prefs.getInt('sleep_end_hour') ?? 5,
    minute: prefs.getInt('sleep_end_minute') ?? 0,
  );

  final start = DateTime(0, 1, 1, sleepStart.hour, sleepStart.minute);
  final end = DateTime(
    0,
    1,
    sleepEnd.hour < sleepStart.hour ? 2 : 1,
    sleepEnd.hour,
    sleepEnd.minute,
  );

  final sleepDuration = end.difference(start);
  return const Duration(hours: 24) - sleepDuration;
}
