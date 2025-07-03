import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/domain/usecases/task/add_task.dart';
import 'package:taskmind_ai/domain/usecases/task/delete_task.dart';
import 'package:taskmind_ai/domain/usecases/task/get_tasks_for_project.dart';
import 'package:taskmind_ai/domain/usecases/task/update_task.dart';
import 'package:taskmind_ai/presentation/providers/task_repository_provider.dart';

final getTasksForProjectProvider = Provider<GetTasksForProject>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return GetTasksForProject(repo);
});

final addTaskProvider = Provider<AddTask>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return AddTask(repo);
});

final deleteTaskProvider = Provider<DeleteTask>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return DeleteTask(repo);
});

final updateTaskProvider = Provider<UpdateTask>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return UpdateTask(repo);
});
