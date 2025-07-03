import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/presentation/providers/task_list_provider.dart';
import 'package:taskmind_ai/presentation/providers/task_usescases_provider.dart';
import 'package:taskmind_ai/services/notification_service.dart';

final taskAddProvider = Provider<TaskAddController>((ref) {
  final addTaskUsecase = ref.watch(addTaskProvider);
  return TaskAddController(ref, addTaskUsecase);
});

class TaskAddController {
  final Ref ref;
  final Future<void> Function(Task) addTask;

  TaskAddController(this.ref, this.addTask);

  Future<void> submit(Task task) async {
    await addTask(task);
    final projectId = task.projectId;
    ref.invalidate(taskListProvider(projectId));

    if (task.dueDate != null) {
      await NotificationService.scheduleTaskReminder(task.title, task.dueDate!, task.id.hashCode);
    }
  }
}
