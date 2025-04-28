import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/comment.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/models/task_date_count.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/http_service.dart';

import 'package:flutter_life_goal_management/src/widgets/task/task_priority_selector_widget.dart';

class TaskService {
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  void showPriorityPopUp(
      BuildContext context, int priority, Function(int) onPriorityChanged) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return TaskPrioritySelectorWidget(
          priority: priority,
          onPriorityChanged: onPriorityChanged,
        );
      },
    );
  }

  // database start

  // Task Part Start
  // Insert a task
  Future<Task?> insertTask(Task task) async {
    //print('subTasks: ${task.subTasks.map((e) => e.toJson())}');
    //print("task: ${task.toJson()}");
    //print("body: ${jsonEncode(task.toJson())}");
    final result = await HttpService().post('tasks',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toJson()));
    //print("result: ${result.body}");
    // Broadcast task changes
    Task insertedTask = Task.fromJson(jsonDecode(result.body));
    TaskBroadcast().notifyTasksChanged(insertedTask);

    // If it's a task with a project, also notify project changes
    if (task.projectId != null) {
      TaskBroadcast().notifyProjectChanged();
    }

    //print("result: ${result.body}");
    return insertedTask;
  }

  // Get All Tasks Count Without sub tasks
  Future<Map<String, dynamic>> getTasksCount() async {
    final result = await HttpService().get('tasks_count', queryParameters: {
      'type': 'all_without_sub_tasks',
    });
    //print("result: ${result.body}");
    return jsonDecode(result.body);
  }

  // Get Inbox Tasks
  Future<List<Task>> getInboxTasks(int page) async {
    final result = await HttpService().get('tasks', queryParameters: {
      'type': 'inbox',
      'page': page,
    });
    final body = jsonDecode(result.body);
    final data = body['data'];
    return List<Task>.from(data.map((e) => Task.fromJson(e)));
  }

  // Get Inbox Tasks Count
  Future<int> getInboxTasksCount() async {
    final result = await HttpService().get('tasks_count', queryParameters: {
      'type': 'inbox',
    });
    return jsonDecode(result.body)['tasks_count'] ?? 0;
  }

  // Get tasks by project_id
  Future<List<Task>> getTasksByProjectId(int projectId, int page) async {
    final result = await HttpService().get('tasks', queryParameters: {
      'project_id': projectId,
      'page': page,
    });
    final body = jsonDecode(result.body);
    final data = body['data'];
    return List<Task>.from(data.map((e) => Task.fromJson(e)));
  }

  // Get tasks by date range
  Future<List<Task>> getTasksByDate(DateTime date, int page) async {
    final result = await HttpService().get('tasks', queryParameters: {
      'date': date.toIso8601String(),
      'page': page,
    });
    final body = jsonDecode(result.body);
    final data = body['data'];
    return List<Task>.from(data.map((e) => Task.fromJson(e)));
  }

  Future<List<TaskDateCount>> getTasksByYearAndMonthCount(
      int year, int month) async {
    final result =
        await HttpService().get('tasks_count_by_date', queryParameters: {
      'year': year,
      'month': month,
    });

    final data = jsonDecode(result.body);
    //print('data: $data');
    return List<TaskDateCount>.from(data.map((e) => TaskDateCount.fromJson(e)));
  }

  // Get today tasks
  Future<List<Task>> getTodayTasks(int page) async {
    final result = await HttpService().get('tasks_list', queryParameters: {
      'page': page,
      'date': DateTime.now().toIso8601String(),
      'per_page': 4,
    });
    //print('result: ${result.body}');
    final data = jsonDecode(result.body)['data'];
    //print('data: $data');
    return List<Task>.from(data.map((e) => Task.fromJson(e)));
  }

  // Get explorer Tasks
  Future<List<Task>> getExplorerTasks(int page, String? search) async {
    final result = await HttpService().get('explore/tasks', queryParameters: {
      'page': page,
      if (search != null) 'search': search,
      'per_page': 20,
    });
    final body = jsonDecode(result.body);
    final data = body['data'];
    //print('data: ${data}');
    return List<Task>.from(data.map((e) => Task.fromJson(e)));
  }

  // Get tasks by parent_id (for subtasks)
  Future<List<Task>> getSubtasks(int parentId, int page) async {
    final result = await HttpService().get('tasks', queryParameters: {
      'parent_id': parentId,
      'page': page,
    });
    final body = jsonDecode(result.body);
    final data = body['data'];
    return List<Task>.from(data.map((e) => Task.fromJson(e)));
  }

  // Update a task
  Future<Map<String, dynamic>> updateTask(Task task) async {
    //print("task: ${task.toJson()}");
    final result = await HttpService().put('tasks/${task.id}',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toJson()));

    //print("result: ${result.body}");

    // Broadcast task changes
    TaskBroadcast().notifyTasksChanged(task);

    // If it's a task with a project, also notify project changes
    if (task.projectId != null) {
      TaskBroadcast().notifyProjectChanged();
    }

    return jsonDecode(result.body);
  }

  // Delete a task and its subtasks
  Future<bool> deleteTask(Task task) async {
    try {
      print("task projectId: ${task.projectId}");
      final result = await HttpService().delete('tasks/${task.id}');

      if (result.statusCode != 204 && result.statusCode != 200) {
        return false;
      }

      // Broadcast task changes
      TaskBroadcast().notifyTasksChanged(task);

      // If it was a project task, also notify project changes
      if (task.projectId != null) {
        TaskBroadcast().notifyProjectChanged();
      }

      return true;
    } catch (e) {
      print('error: ${e.toString()}');
      return false;
    }
  }

  // Like a task
  Future<bool> likeTask(Task task) async {
    final result = await HttpService().post('tasks/${task.id}/like');
    if (result.statusCode == 200) {
      task.likesCount = task.likesCount! + 1;
      TaskBroadcast().notifyTasksChanged(task);
      return true;
    }
    return false;
  }

  // Comment Part Start
  Future<List<Comment>> getComments(int taskId, int page) async {
    final result =
        await HttpService().get('tasks/$taskId/comments', queryParameters: {
      'page': page,
    });

    if (result.statusCode != 200) {
      throw Exception('Failed to load comments');
    }

    final body = jsonDecode(result.body);
    final data = body['data'];

    return List<Comment>.from(data.map((e) => Comment.fromJson(e)));
  }

  Future<Comment> addComment(int taskId, String body) async {
    // Get logged-in user
    final user = await AuthService().getLoggedInUser();
    if (user == null) {
      throw Exception('User not logged in');
    }

    final result = await HttpService().post(
      'tasks/$taskId/comments',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'body': body,
        'user_id': user.id,
      }),
    );

    if (result.statusCode != 200 && result.statusCode != 201) {
      throw Exception('Failed to add comment');
    }

    return Comment.fromJson(jsonDecode(result.body));
  }

  // Comment Part End
}
