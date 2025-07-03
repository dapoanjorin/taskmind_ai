import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/presentation/providers/task_add_provider.dart';
import 'package:taskmind_ai/services/gemini_api_service.dart';

final aiAssistantProvider = StateNotifierProvider<AIAssistantController, AIAssistantState>((ref) {
  return AIAssistantController(ref);
});

class AIAssistantController extends StateNotifier<AIAssistantState> {
  final Ref ref;

  AIAssistantController(this.ref) : super(AIAssistantState.initial());

  Future<void> submitPrompt(String prompt, String projectId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await GeminiApiService.generateTasks(prompt, projectId);
      state = state.copyWith(generatedTasks: tasks, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      print("failing this is the error: $e");
    }
  }

  Future<void> importTask(Task task) async {
    await ref.read(taskAddProvider).submit(task);
  }
}

class AIAssistantState {
  final bool isLoading;
  final String? error;
  final List<Task> generatedTasks;

  AIAssistantState({required this.isLoading, required this.error, required this.generatedTasks});

  factory AIAssistantState.initial() => AIAssistantState(isLoading: false, error: null, generatedTasks: []);

  AIAssistantState copyWith({bool? isLoading, String? error, List<Task>? generatedTasks}) {
    return AIAssistantState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      generatedTasks: generatedTasks ?? this.generatedTasks,
    );
  }
}
