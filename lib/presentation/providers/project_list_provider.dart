import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmind_ai/domain/entities/project.dart';
import 'package:taskmind_ai/presentation/providers/project_use_cases_provider.dart';

final projectListProvider = FutureProvider<List<Project>>((ref) async {
  final getAllProjectsUseCase = ref.watch(getAllProjectsProvider);
  return getAllProjectsUseCase();
});
