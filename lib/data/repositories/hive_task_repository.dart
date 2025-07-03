import 'dart:io';

import 'package:hive/hive.dart';
import 'package:taskmind_ai/data/models/task_model.dart';
import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:taskmind_ai/domain/repositories/task_repository.dart';
import 'package:taskmind_ai/services/mock_api_service.dart';

class HiveTaskRepository implements TaskRepository {
  static const _boxName = 'tasks';
  static const _pendingOperationsBox = 'pending_task_operations';

  Future<void> init() async {
    await Hive.openBox<TaskModel>(_boxName);
    await Hive.openBox<Map>(_pendingOperationsBox);
  }

  Box<TaskModel> get _box => Hive.box<TaskModel>(_boxName);
  Box<Map> get _pendingBox => Hive.box<Map>(_pendingOperationsBox);

  @override
  Future<void> addTask(Task task) async {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      isCompleted: task.isCompleted,
      priority: task.priority.name,
      dueDate: task.dueDate,
    );
    await _box.put(task.id, model);

    try {
      await MockApiService.addTask(task);
      await _pendingBox.delete('add_${task.id}');
    } catch (e) {
      if (_isNetworkError(e)) {
        await _pendingBox.put('add_${task.id}', {
          'type': 'add',
          'task': {
            'id': task.id,
            'title': task.title,
            'isCompleted': task.isCompleted,
            'priority': task.priority.name,
            'dueDate': task.dueDate?.millisecondsSinceEpoch,
          },
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        print('Operation queued for retry: Add task ${task.title}');
      } else {
        await _box.delete(task.id);
        throw Exception('Failed to add task: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final originalModel = _box.get(taskId);

    await _box.delete(taskId);

    try {
      await MockApiService.deleteTask(taskId);
      await _pendingBox.delete('delete_$taskId');
    } catch (e) {
      if (_isNetworkError(e)) {
        await _pendingBox.put('delete_$taskId', {
          'type': 'delete',
          'id': taskId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        print('Operation queued for retry: Delete task $taskId');
      } else {
        if (originalModel != null) {
          await _box.put(taskId, originalModel);
        }
        throw Exception('Failed to delete task: ${e.toString()}');
      }
    }
  }

  @override
  Future<Task?> getTask(String id) async {
    final model = _box.get(id);
    if (model == null) return null;

    return Task(
      id: model.id,
      projectId: model.id.split("_").first,
      title: model.title,
      isCompleted: model.isCompleted,
      priority: TaskPriority.values.firstWhere((p) => p.name == model.priority, orElse: () => TaskPriority.medium),
      dueDate: model.dueDate,
    );
  }

  @override
  Future<List<Task>> getTasksForProject(String projectId) async {
    final localTasks =
        _box.values
            .where((t) => t.id.startsWith("${projectId}_"))
            .map(
              (model) => Task(
                id: model.id,
                projectId: model.id.split("_").first,
                title: model.title,
                isCompleted: model.isCompleted,
                priority: TaskPriority.values.firstWhere(
                  (p) => p.name == model.priority,
                  orElse: () => TaskPriority.medium,
                ),
                dueDate: model.dueDate,
              ),
            )
            .toList();

    _syncTasksWithRemote(projectId);

    return localTasks;
  }

  Future<void> _syncTasksWithRemote(String projectId) async {
    try {
      final remoteTasks = await MockApiService.getTasks(projectId);

      // Clear local storage
      // final keysToDelete = _box.keys.where((key) => key.toString().startsWith("${projectId}_")).toList();
      //
      // for (final key in keysToDelete) {
      //   await _box.delete(key);
      // }

      for (final task in remoteTasks) {
        final model = TaskModel(
          id: task.id,
          title: task.title,
          isCompleted: task.isCompleted,
          priority: task.priority.name,
          dueDate: task.dueDate,
        );
        await _box.put(task.id, model);
      }

      await _processPendingOperations(projectId);
    } catch (e) {
      print('Task sync failed for project $projectId: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final originalModel = _box.get(task.id);

    final model = TaskModel(
      id: task.id,
      title: task.title,
      isCompleted: task.isCompleted,
      priority: task.priority.name,
      dueDate: task.dueDate,
    );
    await _box.put(task.id, model);

    try {
      await MockApiService.updateTask(task);
      await _pendingBox.delete('update_${task.id}');
    } catch (e) {
      if (_isNetworkError(e)) {
        await _pendingBox.put('update_${task.id}', {
          'type': 'update',
          'task': {
            'id': task.id,
            'title': task.title,
            'isCompleted': task.isCompleted,
            'priority': task.priority.name,
            'dueDate': task.dueDate?.millisecondsSinceEpoch,
          },
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        print('Operation queued for retry: Update task ${task.title}');
      } else {
        if (originalModel != null) {
          await _box.put(task.id, originalModel);
        }
        throw Exception('Failed to update task: ${e.toString()}');
      }
    }
  }

  Future<void> _processPendingOperations([String? projectId]) async {
    final pendingOps = _pendingBox.toMap();

    for (final entry in pendingOps.entries) {
      final opData = Map<String, dynamic>.from(entry.value);

      if (projectId != null && opData['type'] != 'delete') {
        final taskData = opData['task'];
        if (taskData != null && !taskData['id'].toString().startsWith("${projectId}_")) {
          continue;
        }
      }

      try {
        switch (opData['type']) {
          case 'add':
            final taskData = opData['task'];
            final task = Task(
              id: taskData['id'],
              projectId: taskData['id'].split('_').first,
              title: taskData['title'],
              isCompleted: taskData['isCompleted'],
              priority: TaskPriority.values.firstWhere(
                (p) => p.name == taskData['priority'],
                orElse: () => TaskPriority.medium,
              ),
              dueDate: taskData['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(taskData['dueDate']) : null,
            );
            await MockApiService.addTask(task);
            await _pendingBox.delete(entry.key);
            print('Synced pending add operation: ${task.title}');
            break;

          case 'delete':
            await MockApiService.deleteTask(opData['id']);
            await _pendingBox.delete(entry.key);
            print('Synced pending delete operation: ${opData['id']}');
            break;

          case 'update':
            final taskData = opData['task'];
            final task = Task(
              id: taskData['id'],
              projectId: taskData['id'].split('_').first,
              title: taskData['title'],
              isCompleted: taskData['isCompleted'],
              priority: TaskPriority.values.firstWhere(
                (p) => p.name == taskData['priority'],
                orElse: () => TaskPriority.medium,
              ),
              dueDate: taskData['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(taskData['dueDate']) : null,
            );
            await MockApiService.updateTask(task);
            await _pendingBox.delete(entry.key);
            print('Synced pending update operation: ${task.title}');
            break;
        }
      } catch (e) {
        print('Failed to sync pending task operation ${entry.key}: ${e.toString()}');
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
