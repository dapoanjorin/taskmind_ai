import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:taskmind_ai/data/models/project_model.dart';
import 'package:taskmind_ai/data/models/task_model.dart';
import 'package:taskmind_ai/presentation/providers/app_state.dart';
import 'package:taskmind_ai/router/app_route_information_parser.dart';
import 'package:taskmind_ai/router/app_router_delegate.dart';
import 'package:taskmind_ai/services/notification_service.dart';

import 'core/constants.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await NotificationService.init();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(ProjectModelAdapter());
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<ProjectModel>('projects');
  await Hive.openBox<Map>('pending_operations');
  await Hive.openBox<Map>('pending_task_operations');

  runApp(const ProviderScope(child: TaskMindApp()));
}

class TaskMindApp extends ConsumerWidget {
  const TaskMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    return MaterialApp.router(
      title: kAppTitle,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      routerDelegate: AppRouterDelegate(appState),
      routeInformationParser: AppRouteInformationParser(),
    );
  }
}
