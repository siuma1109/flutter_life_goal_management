import 'dart:async';

/// A broadcast service for task-related events throughout the app
class TaskBroadcast {
  // Singleton pattern
  static final TaskBroadcast _instance = TaskBroadcast._internal();
  factory TaskBroadcast() => _instance;
  TaskBroadcast._internal();

  // Stream controllers for various events
  final _inboxCountController = StreamController<int>.broadcast();
  final _taskChangedController = StreamController<void>.broadcast();
  final _projectChangedController = StreamController<int?>.broadcast();

  // Streams that other widgets can listen to
  Stream<int> get inboxCountStream => _inboxCountController.stream;
  Stream<void> get taskChangedStream => _taskChangedController.stream;
  Stream<int?> get projectChangedStream => _projectChangedController.stream;

  // Methods to update the inbox count
  void updateInboxCount(int count) {
    _inboxCountController.add(count);
  }

  // Method to notify that tasks have changed
  void notifyTasksChanged() {
    _taskChangedController.add(null);
  }

  // Method to notify that a project has changed
  void notifyProjectChanged([int? projectId]) {
    _projectChangedController.add(projectId);
  }

  // Clean up resources
  void dispose() {
    _inboxCountController.close();
    _taskChangedController.close();
    _projectChangedController.close();
  }
}
