import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/data/repositories/hive_project_repository.dart';
import 'package:taskmind_ai/domain/repositories/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final repo = HiveProjectRepository();
  return repo;
});
