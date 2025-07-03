import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/presentation/providers/selected_project_provider.dart';
import 'package:taskmind_ai/presentation/providers/task_add_provider.dart';
import 'package:uuid/uuid.dart';

class TaskAddDialog extends ConsumerStatefulWidget {
  const TaskAddDialog({super.key});

  @override
  ConsumerState<TaskAddDialog> createState() => _TaskAddDialogState();
}

class _TaskAddDialogState extends ConsumerState<TaskAddDialog> {
  final titleController = TextEditingController();
  TaskPriority priority = TaskPriority.medium;
  DateTime? dueDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Task"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: titleController, decoration: const InputDecoration(labelText: "Task title")),
          const SizedBox(height: 8),
          DropdownButton<TaskPriority>(
            value: priority,
            items:
                TaskPriority.values.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()));
                }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => priority = value);
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(dueDate == null ? "Set Due Date" : dueDate!.toLocal().toString().split(" ").first),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => dueDate = picked);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            final projectId = ref.read(selectedProjectIdProvider);
            if (projectId == null) return;
            final task = Task(
              id: "${projectId}_${const Uuid().v4()}",
              projectId: projectId,
              title: titleController.text.trim(),
              priority: priority,
              dueDate: dueDate,
            );
            await ref.read(taskAddProvider).submit(task);
            Navigator.pop(context);
          },
          child: const Text("Add Task"),
        ),
      ],
    );
  }
}
