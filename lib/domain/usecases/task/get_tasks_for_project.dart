import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/domain/repositories/task_repository.dart';

class GetTasksForProject {
  final TaskRepository repository;

  GetTasksForProject(this.repository);

  Future<List<Task>> call(String projectId) {
    return repository.getTasksForProject(projectId);
  }
}
