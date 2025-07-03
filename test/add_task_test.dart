import 'package:flutter_test/flutter_test.dart';
import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/domain/repositories/task_repository.dart';
import 'package:taskmind_ai/domain/usecases/task/add_task.dart';

class MockTaskRepository implements TaskRepository {
  final List<Task> tasks = [];
  @override
  Future<void> addTask(Task task) async {
    tasks.add(task);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('AddTask use case adds a task to the repository', () async {
    final repo = MockTaskRepository();
    final usecase = AddTask(repo);
    final task = Task(id: '1', projectId: 'p1', title: 'Test Task', isCompleted: false, priority: TaskPriority.medium);
    await usecase(task);
    expect(repo.tasks.length, 1);
    expect(repo.tasks.first.title, 'Test Task');
  });
}
