// To parse this JSON data, do
//
//     final comment = commentFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_life_goal_management/src/models/user.dart';

List<Comment> commentFromJson(String str) =>
    List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

String commentToJson(List<Comment> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Comment {
  int id;
  String commentableType;
  int commentableId;
  String body;
  int userId;
  DateTime createdAt;
  DateTime updatedAt;
  User? user;

  Comment({
    required this.id,
    required this.commentableType,
    required this.commentableId,
    required this.body,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        commentableType: json["commentable_type"],
        commentableId: json["commentable_id"],
        body: json["body"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "commentable_type": commentableType,
        "commentable_id": commentableId,
        "body": body,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "user": user?.toJson(),
      };
}
