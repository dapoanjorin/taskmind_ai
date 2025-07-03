import 'package:taskmind_ai/domain/repositories/project_repository.dart';

class DeleteProject {
  final ProjectRepository repository;
  DeleteProject(this.repository);

  Future<void> call(String id) async {
    await repository.deleteProject(id);
  }
}
