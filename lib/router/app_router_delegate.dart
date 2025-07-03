import 'package:flutter/material.dart';
import 'package:taskmind_ai/presentation/providers/app_state.dart';
import 'package:taskmind_ai/presentation/screens/auth/login_screen.dart';
import 'package:taskmind_ai/presentation/screens/project_list_screen.dart';
import 'package:taskmind_ai/router/app_route_information_parser.dart';

class AppRouterDelegate extends RouterDelegate<AppRouteConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRouteConfiguration> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState appState;

  AppRouterDelegate(this.appState) : navigatorKey = GlobalKey<NavigatorState>() {
    appState.addListener(notifyListeners);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (!appState.isLoggedIn)
          const MaterialPage(child: LoginScreen())
        else
          const MaterialPage(child: ProjectListScreen()),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  @override
  Future<void> setNewRoutePath(AppRouteConfiguration configuration) async {
    return;
  }

  @override
  AppRouteConfiguration? get currentConfiguration {
    return AppRouteConfiguration(
      location: appState.isLoggedIn ? '/dashboard' : '/login',
      isLoggedIn: appState.isLoggedIn,
    );
  }
}
