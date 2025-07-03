import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/domain/entities/project.dart';
import 'package:taskmind_ai/presentation/providers/project_list_provider.dart';
import 'package:taskmind_ai/presentation/providers/project_use_cases_provider.dart';
import 'package:taskmind_ai/presentation/providers/sync_state_provider.dart';

final projectAddProvider = Provider<AddProjectController>((ref) {
  final usecase = ref.watch(addProjectProvider);
  return AddProjectController(ref, usecase);
});

class AddProjectController {
  final Ref ref;
  final Future<void> Function(Project) addProject;

  AddProjectController(this.ref, this.addProject);

  Future<void> submit(Project project) async {
    ref.read(syncStateProvider.notifier).state = SyncState.syncing;
    ref.read(syncErrorProvider.notifier).state = null;
    try {
      await addProject(project);
      ref.read(syncStateProvider.notifier).state = SyncState.idle;
    } catch (e) {
      ref.read(syncStateProvider.notifier).state = SyncState.error;
      ref.read(syncErrorProvider.notifier).state = e.toString();
    }
    ref.invalidate(projectListProvider);
  }
}
