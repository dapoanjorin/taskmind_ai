import 'package:taskmind_ai/domain/entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getAllProjects();
  Future<void> addProject(Project project);
  Future<void> deleteProject(String id);
  Future<void> updateProject(Project project);
  Future<Project?> getProject(String id);
}
