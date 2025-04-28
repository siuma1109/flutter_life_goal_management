import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/notification.dart'
    as notification_model;
import 'package:flutter_life_goal_management/src/widgets/notification/notification_list_item_widget.dart';

class NotificationListWidget extends StatelessWidget {
  final List<notification_model.Notification> notifications;
  final void Function(notification_model.Notification)? onNotificationTap;
  final ScrollController? controller;

  const NotificationListWidget({
    super.key,
    required this.notifications,
    this.onNotificationTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationListItem(
          notification: notification,
          onTap: () => onNotificationTap?.call(notification),
        );
      },
    );
  }
}
