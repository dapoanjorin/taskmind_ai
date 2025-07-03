import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/presentation/providers/task_usescases_provider.dart';

final taskListProvider = FutureProvider.family<List<Task>, String>((ref, projectId) async {
  final taskListUsecase = ref.watch(getTasksForProjectProvider);
  return taskListUsecase(projectId);
});
