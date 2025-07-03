import 'package:flutter_test/flutter_test.dart';
import 'package:taskmind_ai/domain/entities/project.dart';
import 'package:taskmind_ai/domain/repositories/project_repository.dart';
import 'package:taskmind_ai/domain/usecases/project/add_project.dart';

class MockProjectRepository implements ProjectRepository {
  final List<Project> projects = [];
  @override
  Future<void> addProject(Project project) async {
    projects.add(project);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('AddProject use case adds a project to the repository', () async {
    final repo = MockProjectRepository();
    final usecase = AddProject(repo);
    final project = Project(id: '1', name: 'Test', description: 'Desc');
    await usecase(project);
    expect(repo.projects.length, 1);
    expect(repo.projects.first.name, 'Test');
  });
}
