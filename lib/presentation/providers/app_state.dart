import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppState extends ChangeNotifier {
  bool _loggedIn = false;

  bool get isLoggedIn => _loggedIn;

  void login() {
    _loggedIn = true;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    notifyListeners();
  }
}

final appStateProvider = ChangeNotifierProvider<AppState>((ref) => AppState());
