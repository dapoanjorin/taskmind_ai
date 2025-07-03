import 'package:taskmind_ai/domain/entities/project.dart';
import 'package:taskmind_ai/domain/repositories/project_repository.dart';

class GetAllProjects {
  final ProjectRepository repository;

  GetAllProjects(this.repository);

  Future<List<Project>> call() {
    return repository.getAllProjects();
  }
}
