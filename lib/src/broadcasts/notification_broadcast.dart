import 'dart:async';

/// A broadcast service for notification-related events throughout the app
class NotificationBroadcast {
  // Singleton pattern
  static final NotificationBroadcast _instance =
      NotificationBroadcast._internal();
  factory NotificationBroadcast() => _instance;
  NotificationBroadcast._internal();

  // Stream controllers for various events
  final _notificationUnreadCountController = StreamController<void>.broadcast();

  // Streams that other widgets can listen to
  Stream<void> get notificationUnreadCountStream =>
      _notificationUnreadCountController.stream;

  // Method to notify that tasks have changed
  void notifyNotificationUnreadCountChanged() {
    _notificationUnreadCountController.add(null);
  }

  // Clean up resources
  void dispose() {
    _notificationUnreadCountController.close();
  }
}
