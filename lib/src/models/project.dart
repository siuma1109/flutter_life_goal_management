// To parse this JSON data, do
//
//     final project = projectFromJson(jsonString);

import 'dart:convert';

Project projectFromJson(String str) => Project.fromJson(json.decode(str));

String projectToJson(Project data) => json.encode(data.toJson());

class Project {
  int? id;
  String name;
  int userId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? tasksCount;

  Project({
    this.id,
    required this.name,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.tasksCount = 0,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json["id"],
        name: json["name"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        tasksCount: json["tasks_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "user_id": userId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "tasks_count": tasksCount,
      };
}
