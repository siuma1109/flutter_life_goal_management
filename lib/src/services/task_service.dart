import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/services/database_helper.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_priority_selector_widget.dart';
import '../models/task.dart';
import '../widgets/task/view_task_widget.dart';

class TaskService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

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

  void showTaskEditForm(
      BuildContext context, Task task, Function(Task?) onRefresh) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7, // Set height to 0.7
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ViewTaskWidget(
                        task: task,
                        onRefresh: onRefresh,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await _databaseHelper.database;
    task.remove("id");
    task.remove("created_at");
    task.remove("updated_at");
    final result = await db.insert('tasks', task);

    // Broadcast task changes
    TaskBroadcast().notifyTasksChanged();

    // If it's a task with a project, also notify project changes
    if (task['project_id'] != null) {
      TaskBroadcast().notifyProjectChanged(task['project_id']);
    }

    return result;
  }

  // Get Inbox Tasks
  Future<List<Map<String, dynamic>>> getInboxTasks(int userId) async {
    final db = await _databaseHelper.database;
    return await db.query('tasks',
        where: 'user_id = ? AND project_id IS NULL AND parent_id IS NULL',
        whereArgs: [userId]);
  }

  // Get all tasks (including subtasks)
  Future<List<Map<String, dynamic>>> getAllTasks(
      bool withSubTask, int? userId) async {
    final db = await _databaseHelper.database;
    var whereClauses = [];
    var whereArgs = [];

    if (userId != null) {
      whereClauses.add('user_id = ?');
      whereArgs.add(userId);
    }
    if (withSubTask) {
      whereClauses.add('parent_id IS NOT NULL');
    }

    return await db.query('tasks',
        where: whereClauses.join(' AND '), whereArgs: whereArgs);
  }

  // Get task count
  Future<int> getTaskCount(int userId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE user_id = ? AND parent_id IS NULL',
        [userId]);

    return result.first['count'] as int;
  }

  // Get inbox task count
  Future<int> getInboxTaskCount(int userId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE user_id = ? AND project_id IS NULL AND parent_id IS NULL',
        [userId]);

    return result.first['count'] as int;
  }

  // Get tasks by project_id
  Future<List<Map<String, dynamic>>> getTasksByProjectId(int projectId) async {
    final db = await _databaseHelper.database;
    return await db.query(
      'tasks',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  // Get tasks by parent_id (for subtasks)
  Future<List<Map<String, dynamic>>> getSubtasks(int parentId) async {
    final db = await _databaseHelper.database;
    return await db.query(
      'tasks',
      where: 'parent_id = ?',
      whereArgs: [parentId],
    );
  }

  // Get main tasks (tasks without parent)
  Future<List<Map<String, dynamic>>> getMainTasks() async {
    final db = await _databaseHelper.database;
    return await db.query(
      'tasks',
      where: 'parent_id IS NULL',
    );
  }

  // Update a task
  Future<int> updateTask(Map<String, dynamic> task) async {
    final db = await _databaseHelper.database;
    final id = task['id'];
    task.remove("id");

    final result = await db.update(
      'tasks',
      task,
      where: 'id = ?',
      whereArgs: [id],
    );

    // Broadcast task changes
    TaskBroadcast().notifyTasksChanged();

    // If it's a task with a project, also notify project changes
    if (task['project_id'] != null) {
      TaskBroadcast().notifyProjectChanged(task['project_id']);
    }

    return result;
  }

  // Delete a task and its subtasks
  Future<int> deleteTask(int id) async {
    final db = await _databaseHelper.database;

    // Get the task first to check project_id
    final List<Map<String, dynamic>> taskData = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    int? projectId;
    if (taskData.isNotEmpty) {
      projectId = taskData.first['project_id'];
    }

    // First delete all subtasks
    await db.delete(
      'tasks',
      where: 'parent_id = ?',
      whereArgs: [id],
    );

    // Then delete the main task
    final result = await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Broadcast task changes
    TaskBroadcast().notifyTasksChanged();

    // If it was a project task, also notify project changes
    if (projectId != null) {
      TaskBroadcast().notifyProjectChanged(projectId);
    }

    return result;
  }
  // database end
}
