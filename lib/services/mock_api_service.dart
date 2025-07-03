import 'dart:async';
import 'dart:math';

import 'package:taskmind_ai/domain/entities/project.dart';
import 'package:taskmind_ai/domain/entities/task.dart';

class MockApiService {
  static final Map<String, Project> _projects = {};
  static final Map<String, Task> _tasks = {};
  static final Random _random = Random();

  static Future<T> _simulateNetwork<T>(T Function() body) async {
    await Future.delayed(Duration(milliseconds: 855 + _random.nextInt(1200)));
    // random chance to throw error
    if (_random.nextDouble() < 0.1) throw Exception('Network error');
    return body();
  }

  // Project APIs
  static Future<List<Project>> getProjects() async => _simulateNetwork(() => _projects.values.toList());

  static Future<void> addProject(Project project) async => _simulateNetwork(() => _projects[project.id] = project);

  static Future<void> updateProject(Project project) async => _simulateNetwork(() => _projects[project.id] = project);

  static Future<void> deleteProject(String id) async => _simulateNetwork(() => _projects.remove(id));

  // Task APIs
  static Future<List<Task>> getTasks(String projectId) async =>
      _simulateNetwork(() => _tasks.values.where((t) => t.projectId == projectId).toList());

  static Future<void> addTask(Task task) async => _simulateNetwork(() => _tasks[task.id] = task);

  static Future<void> updateTask(Task task) async => _simulateNetwork(() => _tasks[task.id] = task);

  static Future<void> deleteTask(String id) async => _simulateNetwork(() => _tasks.remove(id));
}
