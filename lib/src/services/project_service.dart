import 'dart:convert';

import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/project.dart';
import 'package:flutter_life_goal_management/src/services/http_service.dart';

class ProjectService {
  // Insert a project
  Future<Project?> insertProject(Project project) async {
    final result = await HttpService().post('projects',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(project.toJson()));

    TaskBroadcast().notifyProjectChanged();

    if (result.statusCode == 200 || result.statusCode == 201) {
      try {
        return Project.fromJson(jsonDecode(result.body));
      } catch (e) {
        print("Error parsing project response: $e");
        return null;
      }
    }
    return null;
  }

  // Update a project
  Future<int> updateProject(Project project) async {
    final result = await HttpService()
        .put('projects/${project.id}', body: project.toJson());
    TaskBroadcast().notifyProjectChanged();
    return result.statusCode;
  }

  // Get all projects
  Future<List<Project>> getAllProjects() async {
    final result = await HttpService().get('projects');

    try {
      final List<Project> data = jsonDecode(result.body)
          .map<Project>((json) => Project.fromJson(json))
          .toList();
      return data;
    } catch (e) {
      print("Error parsing projects: $e");
      return [];
    }
  }

  // Get a project
  Future<Project?> getProject(int id) async {
    final result = await HttpService().get('projects/$id');

    try {
      return Project.fromJson(jsonDecode(result.body));
    } catch (e) {
      print("Error parsing project: $e");
      return null;
    }
  }

  // Delete a project
  Future<int> deleteProject(int id) async {
    final result = await HttpService().delete('projects/$id');
    TaskBroadcast().notifyProjectChanged();
    return result.statusCode;
  }
}
