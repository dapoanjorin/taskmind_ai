import 'package:flutter_test/flutter_test.dart';
import 'package:taskmind_ai/domain/entities/project.dart';
import 'package:taskmind_ai/domain/repositories/project_repository.dart';
import 'package:taskmind_ai/domain/usecases/project/get_all_projects.dart';

void main() {
  test('GetAllProjects returns list', () async {
    final fakeRepo = _FakeProjectRepo();
    final getAllProjectsUsecase = GetAllProjects(fakeRepo);

    final result = await getAllProjectsUsecase();
    expect(result.length, 1);
    expect(result.first.name, 'Test Project');
  });
}

class _FakeProjectRepo implements ProjectRepository {
  @override
  Future<List<Project>> getAllProjects() async {
    return [Project(id: '1', name: 'Test Project', description: 'desc')];
  }

  @override
  Future<void> addProject(Project project) async {}

  @override
  Future<void> deleteProject(String id) async {}

  @override
  Future<Project?> getProject(String id) async {}

  @override
  Future<void> updateProject(Project project) async {}
}
