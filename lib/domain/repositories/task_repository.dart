import 'package:taskmind_ai/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasksForProject(String projectId);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<Task?> getTask(String id);
}
