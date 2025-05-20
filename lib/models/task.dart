enum TaskType {
  persistent,
  semiPersistent,
  nonPersistent,
}

class Task {
  final String id;
  final String title;
  final Duration duration;
  final TaskType type;
  final DateTime? date;       // Pour tâche non persistante
  final DateTime? startDate;  // Pour tâche semi-persistante
  final DateTime? endDate;    // Pour tâche semi-persistante
  final bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.duration,
    required this.type,
    this.date,
    this.startDate,
    this.endDate,
    this.isDone = false,
  });

  // Convertit un Task en Map (pour SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration.inMinutes,
      'type': type.index,
      'date': date?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isDone': isDone ? 1 : 0,
    };
  }

  // Convertit une Map SQL en Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      duration: Duration(minutes: map['duration']),
      type: TaskType.values[map['type']],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      isDone: map['isDone'] == 1,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    Duration? duration,
    TaskType? type,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      date: date ?? this.date,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isDone: isDone ?? this.isDone,
    );
  }

}
