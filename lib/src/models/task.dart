// To parse this JSON data, do
//
//     final task = taskFromJson(jsonString);

import 'dart:convert';

Task taskFromJson(String str) => Task.fromJson(json.decode(str));

String taskToJson(Task data) => json.encode(data.toJson());

class Task {
  int? id;
  int? parentId;
  int? userId;
  int? projectId;
  String title;
  String? description;
  DateTime? dueDate;
  int priority;
  bool isChecked;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Task> subTasks;

  Task({
    this.id,
    this.parentId,
    this.userId,
    this.projectId,
    required this.title,
    this.description = '',
    this.dueDate,
    required this.priority,
    required this.isChecked,
    this.createdAt,
    this.updatedAt,
    required this.subTasks,
  }) {
    createdAt = createdAt ?? DateTime.now();
    updatedAt = updatedAt ?? DateTime.now();
  }

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"],
        parentId: json["parent_id"],
        userId: json["user_id"],
        projectId: json["project_id"],
        title: json["title"] ?? "",
        description: json["description"],
        dueDate:
            json["due_date"] != null ? DateTime.parse(json["due_date"]) : null,
        priority: json["priority"],
        isChecked: json["is_checked"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        subTasks:
            List<Task>.from(json["sub_tasks"].map((x) => Task.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "user_id": userId,
        "project_id": projectId,
        "title": title,
        "description": description,
        "due_date": dueDate?.toIso8601String(),
        "priority": priority,
        "is_checked": isChecked,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "sub_tasks":
            List<Map<String, dynamic>>.from(subTasks.map((x) => x.toJson())),
      };

  Task copyWith({
    int? id,
    int? parentId,
    int? userId,
    int? projectId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    bool? isChecked,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Task>? subTasks,
  }) {
    return Task(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subTasks: subTasks ?? this.subTasks,
    );
  }
}
