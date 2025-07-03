import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncStateProvider = StateProvider<SyncState>((ref) => SyncState.idle);
final syncErrorProvider = StateProvider<String?>((ref) => null);

enum SyncState { idle, syncing, error }
