import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/domain/repositories/task_repository.dart';

class UpdateTask {
  final TaskRepository repository;
  UpdateTask(this.repository);

  Future<void> call(Task task) async {
    await repository.updateTask(task);
  }
}
