import 'dart:async';

import 'package:flutter_life_goal_management/src/models/task.dart';

/// A broadcast service for task-related events throughout the app
class TaskBroadcast {
  // Singleton pattern
  static final TaskBroadcast _instance = TaskBroadcast._internal();
  factory TaskBroadcast() => _instance;
  TaskBroadcast._internal();

  // Stream controllers for various events
  final _taskChangedController = StreamController<Task?>.broadcast();
  final _projectChangedController = StreamController<void>.broadcast();

  // Streams that other widgets can listen to
  Stream<Task?> get taskChangedStream => _taskChangedController.stream;
  Stream<void> get projectChangedStream => _projectChangedController.stream;

  // Method to notify that tasks have changed
  void notifyTasksChanged(Task? task) {
    _taskChangedController.add(task ?? null);
  }

  // Method to notify that a project has changed
  void notifyProjectChanged() {
    print("notifyProjectChanged");
    _projectChangedController.add(null);
  }

  // Clean up resources
  void dispose() {
    _taskChangedController.close();
    _projectChangedController.close();
  }
}
