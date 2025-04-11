import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/project.dart';
import 'package:flutter_life_goal_management/src/services/database_helper.dart';

class ProjectService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Insert a project
  Future<int> insertProject(Project project) async {
    print("inserting project: ${project.toMap()}");
    final db = await _databaseHelper.database;
    Map<String, dynamic> projectMap = project.toMap();
    projectMap.remove('task_count');
    final result = await db.insert('projects', projectMap);
    TaskBroadcast().notifyProjectChanged();
    print("result: $result");
    return result;
  }

  // Update a project
  Future<int> updateProject(Project project) async {
    final db = await _databaseHelper.database;
    final result = await db.update('projects', project.toMap(),
        where: 'id = ?', whereArgs: [project.id]);
    TaskBroadcast().notifyProjectChanged();
    return result;
  }

  // Get all projects
  Future<List<Map<String, dynamic>>> getAllProjectsByUserId(int userId) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
          SELECT *, (
          SELECT COUNT(*) FROM tasks WHERE project_id = projects.id) as task_count 
          FROM projects WHERE user_id = ?
        ''', [userId]);
  }

  // Get a project
  Future<Project> getProject(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query('projects', where: 'id = ?', whereArgs: [id]);
    return Project.fromMap(result.first);
  }

  // Delete a project
  Future<int> deleteProject(int id) async {
    final db = await _databaseHelper.database;
    final result =
        await db.delete('projects', where: 'id = ?', whereArgs: [id]);
    TaskBroadcast().notifyProjectChanged();
    return result;
  }
}
