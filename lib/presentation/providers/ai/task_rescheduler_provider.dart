import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/presentation/providers/task_add_provider.dart';
import 'package:taskmind_ai/services/gemini_api_service.dart';

final taskReschedulerProvider = Provider<TaskRescheduler>((ref) {
  return TaskRescheduler(ref);
});

class TaskRescheduler {
  final Ref ref;
  TaskRescheduler(this.ref);

  Future<DateTime?> suggestNewTime(Task task) async {
    final prompt =
        "This task is overdue: \"${task.title}\". Suggest a better time to reschedule it "
        "in the format: {\"dueDate\": \"YYYY-MM-DD\"}. Only return valid JSON.";
    try {
      final raw = await GeminiApiService.generateReschedule(prompt);
      final newDate = DateTime.tryParse(raw);
      if (newDate != null) {
        final updated = task.copyWith(dueDate: newDate);
        await ref.read(taskAddProvider).submit(updated);
      }
      return newDate;
    } catch (_) {
      return null;
    }
  }
}
