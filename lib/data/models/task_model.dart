import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final String priority;

  @HiveField(4)
  final DateTime? dueDate;

  TaskModel({required this.id, required this.title, this.isCompleted = false, this.priority = 'Medium', this.dueDate});
}
