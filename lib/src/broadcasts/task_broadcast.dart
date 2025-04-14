import 'dart:async';

/// A broadcast service for task-related events throughout the app
class TaskBroadcast {
  // Singleton pattern
  static final TaskBroadcast _instance = TaskBroadcast._internal();
  factory TaskBroadcast() => _instance;
  TaskBroadcast._internal();

  // Stream controllers for various events
  final _taskChangedController = StreamController<void>.broadcast();
  final _projectChangedController = StreamController<int?>.broadcast();

  // Streams that other widgets can listen to
  Stream<void> get taskChangedStream => _taskChangedController.stream;
  Stream<int?> get projectChangedStream => _projectChangedController.stream;

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
    _taskChangedController.close();
    _projectChangedController.close();
  }
}
