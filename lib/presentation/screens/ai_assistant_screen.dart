import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/presentation/providers/ai/ai_assistant_provider.dart';
import 'package:taskmind_ai/presentation/providers/selected_project_provider.dart';

class AIAssistantScreen extends ConsumerWidget {
  const AIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(aiAssistantProvider);
    final state = ref.watch(aiAssistantProvider.notifier);

    final selectedProject = ref.watch(selectedProjectIdProvider);
    final promptController = TextEditingController(text: "Need gym stuff");

    void submitPrompt() {
      state.submitPrompt(promptController.text.trim(), selectedProject!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: promptController,
              decoration: const InputDecoration(labelText: "What do you want help with?", border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: controller.isLoading || selectedProject == null ? null : submitPrompt,
              icon: const Icon(Icons.send),
              label: const Text("Generate Tasks"),
            ),
            const SizedBox(height: 20),
            if (controller.isLoading) const CircularProgressIndicator(),
            if (controller.error != null) Text("❌ ${controller.error}", style: const TextStyle(color: Colors.red)),
            if (controller.generatedTasks.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: controller.generatedTasks.length,
                  itemBuilder: (_, i) {
                    final task = controller.generatedTasks[i];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.priority.name.toUpperCase()),
                      trailing: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () async {
                          await state.importTask(task);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
