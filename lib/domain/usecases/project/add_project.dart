import 'package:taskmind_ai/domain/entities/project.dart';
import 'package:taskmind_ai/domain/repositories/project_repository.dart';

class AddProject {
  final ProjectRepository repository;

  AddProject(this.repository);

  Future<void> call(Project project) {
    return repository.addProject(project);
  }
}
