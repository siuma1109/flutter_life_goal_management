import 'dart:async';

/// A broadcast service for user-related events throughout the app
class UserBroadcast {
  // Singleton pattern
  static final UserBroadcast _instance = UserBroadcast._internal();
  factory UserBroadcast() => _instance;
  UserBroadcast._internal();

  // Stream controllers for various events
  final _userChangedController = StreamController<void>.broadcast();

  // Streams that other widgets can listen to
  Stream<void> get userChangedStream => _userChangedController.stream;

  // Method to notify that user has changed
  void notifyUserChanged() {
    print("notifyUserChanged");
    _userChangedController.add(null);
  }

  // Clean up resources
  void dispose() {
    _userChangedController.close();
  }
}
