// To parse this JSON data, do
//
//     final task = taskFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_life_goal_management/src/models/comment.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

Task taskFromJson(String str) => Task.fromJson(json.decode(str));

String taskToJson(Task data) => json.encode(data.toJson());

class Task {
  int? id;
  int? parentId;
  int? userId;
  int? projectId;
  String title;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  int priority;
  bool isChecked;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Task> subTasks;
  User? user;
  int? likesCount;
  int? commentsCount;
  int? sharesCount;
  List<Comment> comments;
  bool? isLiked;
  bool? isDeleted;

  static final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  Task({
    this.id,
    this.parentId,
    this.userId,
    this.projectId,
    required this.title,
    this.description = '',
    this.startDate,
    this.endDate,
    required this.priority,
    required this.isChecked,
    this.createdAt,
    this.updatedAt,
    required this.subTasks,
    this.user,
    this.likesCount,
    this.commentsCount,
    this.sharesCount,
    this.comments = const [],
    this.isLiked,
    this.isDeleted = false,
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
        startDate: json["start_date"] != null
            ? DateTime.parse(json["start_date"])
            : null,
        endDate:
            json["end_date"] != null ? DateTime.parse(json["end_date"]) : null,
        priority: json["priority"],
        isChecked: json["is_checked"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        subTasks: json["sub_tasks"] != null
            ? List<Task>.from(json["sub_tasks"].map((x) => Task.fromJson(x)))
            : <Task>[],
        user: json["user"] != null ? User.fromJson(json["user"]) : null,
        likesCount: json["likes_count"] ?? 0,
        commentsCount: json["comments_count"] ?? 0,
        sharesCount: json["shares_count"] ?? 0,
        comments: json["comments"] != null
            ? List<Comment>.from(
                json["comments"].map((x) => Comment.fromJson(x)))
            : <Comment>[],
        isLiked: json["is_liked"] != null
            ? json["is_liked"] > 0
                ? true
                : false
            : false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "user_id": userId,
        "project_id": projectId,
        "title": title,
        "description": description,
        "start_date": startDate == null ? null : dateFormat.format(startDate!),
        "end_date": endDate == null ? null : dateFormat.format(endDate!),
        "priority": priority,
        "is_checked": isChecked,
        "created_at": createdAt == null ? null : dateFormat.format(createdAt!),
        "updated_at": updatedAt == null ? null : dateFormat.format(updatedAt!),
        "sub_tasks":
            List<Map<String, dynamic>>.from(subTasks.map((x) => x.toJson())),
        "user": user == null ? null : user!.toJson(),
        "likes_count": likesCount,
        "comments_count": commentsCount,
        "shares_count": sharesCount,
        "comments":
            List<Map<String, dynamic>>.from(comments.map((x) => x.toJson())),
        "is_liked": isLiked == true ? 1 : 0,
      };

  Task copyWith({
    int? id,
    int? parentId,
    int? userId,
    int? projectId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
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
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subTasks: subTasks ?? this.subTasks,
      user: user ?? this.user,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  String get createdAtFormatted =>
      createdAt != null ? timeago.format(createdAt!) : '';
  String get updatedAtFormatted =>
      updatedAt != null ? timeago.format(updatedAt!) : '';
}
