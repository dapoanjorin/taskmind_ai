import 'package:taskmind_ai/domain/entities/project.dart';
import 'package:taskmind_ai/domain/repositories/project_repository.dart';

class UpdateProject {
  final ProjectRepository repository;
  UpdateProject(this.repository);

  Future<void> call(Project project) async {
    await repository.updateProject(project);
  }
}
