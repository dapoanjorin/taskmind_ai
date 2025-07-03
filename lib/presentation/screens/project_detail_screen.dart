import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/presentation/providers/ai/task_rescheduler_provider.dart';
import 'package:taskmind_ai/presentation/providers/selected_project_provider.dart';
import 'package:taskmind_ai/presentation/providers/sync_state_provider.dart';
import 'package:taskmind_ai/presentation/providers/task_list_provider.dart';
import 'package:taskmind_ai/presentation/providers/task_usescases_provider.dart';
import 'package:taskmind_ai/presentation/screens/task_add_dialog.dart';

import 'ai_assistant_screen.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Task> _tasks = [];
  List<Task> _previousTasks = [];

  void _showEditTaskDialog(BuildContext context, WidgetRef ref, dynamic task, String projectId) {
    final titleController = TextEditingController(text: task.title);
    TaskPriority priority = task.priority;
    DateTime? dueDate = task.dueDate;

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Edit Task"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: "Task title"),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<TaskPriority>(
                        value: priority,
                        items:
                            TaskPriority.values.map((p) {
                              return DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()));
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              priority = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(dueDate == null ? "Set Due Date" : dueDate!.toLocal().toString().split(" ").first),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              dueDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    ElevatedButton(
                      onPressed: () async {
                        final updated = task.copyWith(
                          title: titleController.text.trim(),
                          priority: priority,
                          dueDate: dueDate,
                        );
                        await ref.read(updateTaskProvider).call(updated);
                        ref.invalidate(taskListProvider(projectId));
                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildTaskItem(Task task, String projectId, Animation<double> animation) {
    final isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now());

    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          child: ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : null,
              ),
            ),
            subtitle: Text(
              "${task.priority.name.toUpperCase()} | Due: ${task.dueDate?.toLocal().toString().split(" ").first ?? "None"}",
              style: TextStyle(
                color: isOverdue && !task.isCompleted ? Colors.red : null,
                fontWeight: isOverdue && !task.isCompleted ? FontWeight.bold : null,
              ),
            ),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (val) async {
                final updated = task.copyWith(isCompleted: val ?? false);
                await ref.read(updateTaskProvider).call(updated);
                ref.invalidate(taskListProvider(projectId));
              },
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isOverdue && !task.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final newDate = await ref.read(taskReschedulerProvider).suggestNewTime(task);
                        if (newDate != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Rescheduled to ${newDate.toLocal().toString().split(' ').first}"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text("Reschedule", style: TextStyle(fontSize: 12, color: Colors.red)),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _showEditTaskDialog(context, ref, task, projectId);
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Delete Task'),
                              content: const Text('Are you sure you want to delete this task?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await ref.read(deleteTaskProvider).call(task.id);
                        ref.invalidate(taskListProvider(projectId));
                      }
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')]),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemovedTaskItem(Task task, String projectId, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1, 0)).chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          color: Colors.red.shade50,
          child: ListTile(
            title: Text(task.title, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
            subtitle: Text(
              "${task.priority.name.toUpperCase()} | Due: ${task.dueDate?.toLocal().toString().split(" ").first ?? "None"}",
              style: const TextStyle(color: Colors.grey),
            ),
            leading: const Icon(Icons.check_circle, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _updateTaskList(List<Task> newTasks) {
    final addedTasks = newTasks.where((task) => !_previousTasks.any((prev) => prev.id == task.id)).toList();

    final removedTasks = _previousTasks.where((task) => !newTasks.any((current) => current.id == task.id)).toList();

    for (final removedTask in removedTasks) {
      final index = _tasks.indexWhere((task) => task.id == removedTask.id);
      if (index != -1) {
        final task = _tasks.removeAt(index);
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _buildRemovedTaskItem(task, ref.read(selectedProjectIdProvider) ?? '', animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    for (final addedTask in addedTasks) {
      _tasks.add(addedTask);
      _listKey.currentState?.insertItem(_tasks.length - 1, duration: const Duration(milliseconds: 300));
    }

    for (int i = 0; i < newTasks.length; i++) {
      final newTask = newTasks[i];
      final existingIndex = _tasks.indexWhere((task) => task.id == newTask.id);
      if (existingIndex != -1) {
        _tasks[existingIndex] = newTask;
      }
    }

    _previousTasks = List.from(newTasks);
  }

  @override
  Widget build(BuildContext context) {
    final projectId = ref.watch(selectedProjectIdProvider);
    if (projectId == null) {
      return const Scaffold(body: Center(child: Text("No project selected")));
    }

    final taskListAsync = ref.watch(taskListProvider(projectId));
    final syncState = ref.watch(syncStateProvider);
    final syncError = ref.watch(syncErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        elevation: 2,
        actions: [
          if (syncState == SyncState.syncing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: 'AI Assistant',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AIAssistantScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (syncError != null)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(child: Text(syncError, style: TextStyle(color: Colors.red.shade700))),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => ref.read(syncErrorProvider.notifier).state = null,
                  ),
                ],
              ),
            ),
          taskListAsync.when(
            loading:
                () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Loading tasks...", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
            error:
                (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text("Error loading tasks", style: TextStyle(fontSize: 18, color: Colors.red.shade700)),
                      const SizedBox(height: 8),
                      Text(
                        "$e",
                        style: TextStyle(fontSize: 14, color: Colors.red.shade500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(taskListProvider(projectId)),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
            data: (tasks) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateTaskList(tasks);
              });

              if (tasks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No tasks yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text(
                        "Tap the + button to add your first task",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return AnimatedList(
                key: _listKey,
                initialItemCount: _tasks.length,
                itemBuilder: (context, index, animation) {
                  if (index >= _tasks.length) return const SizedBox.shrink();
                  return _buildTaskItem(_tasks[index], projectId, animation);
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const TaskAddDialog()),
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
