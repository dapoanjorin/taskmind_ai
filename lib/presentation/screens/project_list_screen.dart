import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/domain/entities/project.dart';
import 'package:taskmind_ai/presentation/providers/project_add_provider.dart';
import 'package:taskmind_ai/presentation/providers/project_list_provider.dart';
import 'package:taskmind_ai/presentation/providers/project_use_cases_provider.dart';
import 'package:taskmind_ai/presentation/providers/selected_project_provider.dart';
import 'package:taskmind_ai/presentation/providers/sync_state_provider.dart';
import 'package:taskmind_ai/presentation/screens/project_detail_screen.dart';
import 'package:uuid/uuid.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  void _showDeleteProjectDialog(BuildContext context, WidgetRef ref, Project project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Project'),
            content: const Text('Are you sure you want to delete this project?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
    );
    if (confirm == true) {
      await ref.read(deleteProjectProvider).call(project.id);
      ref.invalidate(projectListProvider);
    }
  }

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("New Project"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  final id = const Uuid().v4();
                  final project = Project(
                    id: id,
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                  );
                  await ref.read(projectAddProvider).submit(project);
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  void _showEditProjectDialog(BuildContext context, WidgetRef ref, Project project) {
    final nameController = TextEditingController(text: project.name);
    final descController = TextEditingController(text: project.description);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Project"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  final updated = project.copyWith(
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                  );
                  await ref.read(updateProjectProvider).call(updated);
                  ref.invalidate(projectListProvider);
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectListAsync = ref.watch(projectListProvider);
    final syncState = ref.watch(syncStateProvider);
    final syncError = ref.watch(syncErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Projects"),
        actions: [
          if (syncState == SyncState.syncing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
          Expanded(
            child: projectListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
              data:
                  (projects) => ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ListTile(
                        title: Text(project.name),
                        subtitle: Text(project.description),
                        onTap: () {
                          ref.read(selectedProjectIdProvider.notifier).state = project.id;
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const ProjectDetailScreen(),
                              transitionsBuilder: (_, anim, __, child) {
                                return FadeTransition(opacity: anim, child: child);
                              },
                            ),
                          );
                        },
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _showEditProjectDialog(context, ref, project);
                            } else if (value == 'delete') {
                              _showDeleteProjectDialog(context, ref, project);
                            }
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
