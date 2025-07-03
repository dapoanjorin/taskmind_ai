import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/domain/repositories/task_repository.dart';

class AddTask {
  final TaskRepository repository;

  AddTask(this.repository);

  Future<void> call(Task task) {
    return repository.addTask(task);
  }
}
