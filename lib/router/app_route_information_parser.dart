import 'package:flutter/material.dart';

class AppRouteConfiguration {
  final String location;
  final bool isLoggedIn;

  AppRouteConfiguration({required this.location, required this.isLoggedIn});
}

class AppRouteInformationParser extends RouteInformationParser<AppRouteConfiguration> {
  @override
  Future<AppRouteConfiguration> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '/');

    return AppRouteConfiguration(location: uri.path, isLoggedIn: false);
  }
}
