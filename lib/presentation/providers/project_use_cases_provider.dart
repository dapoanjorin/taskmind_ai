import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/domain/usecases/project/add_project.dart';
import 'package:taskmind_ai/domain/usecases/project/delete_project.dart';
import 'package:taskmind_ai/domain/usecases/project/get_all_projects.dart';
import 'package:taskmind_ai/domain/usecases/project/update_project.dart';
import 'package:taskmind_ai/presentation/providers/project_repository_provider.dart';

final getAllProjectsProvider = Provider<GetAllProjects>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return GetAllProjects(repo);
});

final addProjectProvider = Provider<AddProject>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return AddProject(repo);
});

final deleteProjectProvider = Provider<DeleteProject>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return DeleteProject(repo);
});

final updateProjectProvider = Provider<UpdateProject>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return UpdateProject(repo);
});
