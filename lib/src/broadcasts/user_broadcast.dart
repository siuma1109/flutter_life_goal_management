import 'dart:async';

import 'package:flutter_life_goal_management/src/models/user.dart';

/// A broadcast service for user-related events throughout the app
class UserBroadcast {
  // Singleton pattern
  static final UserBroadcast _instance = UserBroadcast._internal();
  factory UserBroadcast() => _instance;
  UserBroadcast._internal();

  // Stream controllers for various events
  final _userChangedController = StreamController<User?>.broadcast();

  // Streams that other widgets can listen to
  Stream<User?> get userChangedStream => _userChangedController.stream;

  // Method to notify that user has changed
  void notifyUserChanged({User? user}) {
    print("notifyUserChanged");
    _userChangedController.add(user);
  }

  // Clean up resources
  void dispose() {
    _userChangedController.close();
  }
}
