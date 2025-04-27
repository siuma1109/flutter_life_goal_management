// To parse this JSON data, do
//
//     final feed = feedFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

List<Feed> feedFromJson(String str) =>
    List<Feed>.from(json.decode(str).map((x) => Feed.fromJson(x)));

String feedToJson(List<Feed> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Feed {
  int id;
  String feedableType;
  int feedableId;
  String body;
  int userId;
  DateTime createdAt;
  DateTime updatedAt;
  User? user;
  int? likesCount;
  int? commentsCount;
  int? sharesCount;
  String? link;
  bool? isLiked;
  Feed({
    required this.id,
    required this.feedableType,
    required this.feedableId,
    required this.body,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.likesCount,
    this.commentsCount,
    this.sharesCount,
    this.link,
    this.isLiked,
  });

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        id: json["id"],
        feedableType: json["feedable_type"],
        feedableId: json["feedable_id"],
        body: json["body"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        user: User.fromJson(json["user"]),
        likesCount: json["likes_count"] ?? 0,
        commentsCount: json["comments_count"] ?? 0,
        sharesCount: json["shares_count"] ?? 0,
        link: json["link"] ?? "",
        isLiked: json["is_liked"] == 1 ? true : false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "feedable_type": feedableType,
        "feedable_id": feedableId,
        "body": body,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "user": user?.toJson(),
        "likes_count": likesCount,
        "comments_count": commentsCount,
        "shares_count": sharesCount,
        "link": link,
        "is_liked": isLiked == true ? 1 : 0,
      };

  String get createdAtFormatted => timeago.format(createdAt);
  String get updatedAtFormatted => timeago.format(updatedAt);
}
