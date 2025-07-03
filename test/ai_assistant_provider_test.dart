import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/presentation/providers/ai/ai_assistant_provider.dart';

void main() {
  test('AI Assistant provider initial state is correct', () {
    final container = ProviderContainer();
    final state = container.read(aiAssistantProvider);
    expect(state.isLoading, false);
    expect(state.generatedTasks, isEmpty);
    expect(state.error, isNull);
  });
}
