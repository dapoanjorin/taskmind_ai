enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String projectId;
  final String title;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? dueDate;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
