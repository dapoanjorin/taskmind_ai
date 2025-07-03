import 'dart:io';

import 'package:hive/hive.dart';
import 'package:taskmind_ai/data/models/project_model.dart';
import 'package:taskmind_ai/domain/entities/project.dart';
import 'package:taskmind_ai/domain/repositories/project_repository.dart';
import 'package:taskmind_ai/services/mock_api_service.dart';

class HiveProjectRepository implements ProjectRepository {
  static const _boxName = 'projects';
  static const _pendingOperationsBox = 'pending_operations';

  Future<void> init() async {
    await Hive.openBox<ProjectModel>(_boxName);
    await Hive.openBox<Map>(_pendingOperationsBox);
  }

  Box<ProjectModel> get _box => Hive.box<ProjectModel>(_boxName);
  Box<Map> get _pendingBox => Hive.box<Map>(_pendingOperationsBox);

  @override
  Future<List<Project>> getAllProjects() async {
    final localProjects =
        _box.values.map((model) => Project(id: model.id, name: model.name, description: model.description)).toList();

    _syncWithRemote();

    return localProjects;
  }

  Future<void> _syncWithRemote() async {
    try {
      final remoteProjects = await MockApiService.getProjects();

      // Cleaer local storage
      // await _box.clear();
      for (final project in remoteProjects) {
        final model = ProjectModel(id: project.id, name: project.name, description: project.description);
        await _box.put(project.id, model);
      }

      await _processPendingOperations();
    } catch (e) {
      print('Sync failed: ${e.toString()}');
    }
  }

  @override
  Future<void> addProject(Project project) async {
    final model = ProjectModel(id: project.id, name: project.name, description: project.description);
    await _box.put(project.id, model);

    try {
      await MockApiService.addProject(project);
      await _pendingBox.delete('add_${project.id}');
    } catch (e) {
      if (_isNetworkError(e)) {
        await _pendingBox.put('add_${project.id}', {
          'type': 'add',
          'project': {'id': project.id, 'name': project.name, 'description': project.description},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        print('Operation queued for retry: Add project ${project.name}');
      } else {
        await _box.delete(project.id);
        throw Exception('Failed to add project: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    final originalModel = _box.get(id);

    await _box.delete(id);

    try {
      await MockApiService.deleteProject(id);
      await _pendingBox.delete('delete_$id');
    } catch (e) {
      if (_isNetworkError(e)) {
        await _pendingBox.put('delete_$id', {
          'type': 'delete',
          'id': id,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        print('Operation queued for retry: Delete project $id');
      } else {
        if (originalModel != null) {
          await _box.put(id, originalModel);
        }
        throw Exception('Failed to delete project: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> updateProject(Project project) async {
    final originalModel = _box.get(project.id);

    final model = ProjectModel(id: project.id, name: project.name, description: project.description);
    await _box.put(project.id, model);

    try {
      await MockApiService.updateProject(project);
      await _pendingBox.delete('update_${project.id}');
    } catch (e) {
      if (_isNetworkError(e)) {
        await _pendingBox.put('update_${project.id}', {
          'type': 'update',
          'project': {'id': project.id, 'name': project.name, 'description': project.description},
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        print('Operation queued for retry: Update project ${project.name}');
      } else {
        if (originalModel != null) {
          await _box.put(project.id, originalModel);
        }
        throw Exception('Failed to update project: ${e.toString()}');
      }
    }
  }

  @override
  Future<Project?> getProject(String id) async {
    final model = _box.get(id);
    if (model == null) return null;

    return Project(id: model.id, name: model.name, description: model.description);
  }

  Future<void> _processPendingOperations() async {
    final pendingOps = _pendingBox.toMap();

    for (final entry in pendingOps.entries) {
      final opData = Map<String, dynamic>.from(entry.value);

      try {
        switch (opData['type']) {
          case 'add':
            final projectData = opData['project'];
            final project = Project(
              id: projectData['id'],
              name: projectData['name'],
              description: projectData['description'],
            );
            await MockApiService.addProject(project);
            await _pendingBox.delete(entry.key);
            print('Synced pending add operation: ${project.name}');
            break;

          case 'delete':
            await MockApiService.deleteProject(opData['id']);
            await _pendingBox.delete(entry.key);
            print('Synced pending delete operation: ${opData['id']}');
            break;

          case 'update':
            final projectData = opData['project'];
            final project = Project(
              id: projectData['id'],
              name: projectData['name'],
              description: projectData['description'],
            );
            await MockApiService.updateProject(project);
            await _pendingBox.delete(entry.key);
            print('Synced pending update operation: ${project.name}');
            break;
        }
      } catch (e) {
        print('Failed to sync pending operation ${entry.key}: ${e.toString()}');
      }
    }
  }

  bool _isNetworkError(dynamic error) {
    return error is SocketException ||
        error is HttpException ||
        error.toString().contains('network') ||
        error.toString().contains('timeout') ||
        error.toString().contains('connection');
  }
}
