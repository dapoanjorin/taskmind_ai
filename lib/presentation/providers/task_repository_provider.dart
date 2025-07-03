import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/data/repositories/hive_task_repository.dart';
import 'package:taskmind_ai/domain/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final repo = HiveTaskRepository();
  return repo;
});
