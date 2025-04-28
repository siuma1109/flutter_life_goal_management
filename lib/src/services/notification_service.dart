import 'dart:convert';

import 'package:flutter_life_goal_management/src/broadcasts/notification_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/notification.dart';
import 'package:flutter_life_goal_management/src/services/http_service.dart';

class NotificationService {
  Future<List<Notification>> getNotifications(int page) async {
    final response = await HttpService().get('notifications', queryParameters: {
      'page': page,
    });

    final data = jsonDecode(response.body)['data'];
    return List<Notification>.from(data.map((e) => Notification.fromJson(e)));
  }

  Future<int> getNotificationsUnreadCount() async {
    final response = await HttpService().get('notifications/unread_count');
    return jsonDecode(response.body)['unread_count'] ?? 0;
  }

  Future<bool> markNotificationAsRead(String id) async {
    final response = await HttpService().post('notifications/read', body: {
      'notification_id': id,
    });

    if (response.statusCode == 200) {
      NotificationBroadcast().notifyNotificationUnreadCountChanged();
      return true;
    }

    return false;
  }
}
