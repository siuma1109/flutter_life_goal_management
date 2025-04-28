// To parse this JSON data, do
//
//     final notification = notificationFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_life_goal_management/src/utils/notification_utils.dart';

List<Notification> notificationFromJson(String str) => List<Notification>.from(
    json.decode(str).map((x) => Notification.fromJson(x)));

String notificationToJson(List<Notification> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Notification {
  String id;
  String type;
  String notifiableType;
  int notifiableId;
  Map<String, dynamic> data;
  dynamic readAt;
  DateTime createdAt;
  DateTime updatedAt;

  Notification({
    required this.id,
    required this.type,
    required this.notifiableType,
    required this.notifiableId,
    required this.data,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["id"],
        type: json["type"],
        notifiableType: json["notifiable_type"],
        notifiableId: json["notifiable_id"],
        data: json["data"] ?? {},
        readAt: json["read_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "notifiable_type": notifiableType,
        "notifiable_id": notifiableId,
        "data": data,
        "read_at": readAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  String? get username {
    return data.containsKey('user') && data['user'] is Map
        ? data['user']['name'] as String?
        : null;
  }

  String? get userAvatar {
    return data.containsKey('user') && data['user'] is Map
        ? data['user']['avatar'] as String?
        : null;
  }

  String? get content {
    return data.containsKey('content') ? data['content'] as String? : null;
  }

  bool get isRead => readAt != null;

  int? get relatedId {
    final relatedTypeKey =
        NotificationUtils.getNotificationRelatedTypeKey(this);
    print('relatedTypeKey: $relatedTypeKey');
    return data.containsKey(relatedTypeKey) && data[relatedTypeKey] is Map
        ? data[relatedTypeKey]['id'] as int?
        : null;
  }

  String? get relatedType {
    return data.containsKey('type') ? data['type'] as String? : null;
  }
}
