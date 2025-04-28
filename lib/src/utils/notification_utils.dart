import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/notification.dart'
    as notification_model;
import 'package:go_router/go_router.dart';

enum NotificationType {
  taskComment,
  taskCompleted,
  taskReminder,
  follow,
  unknown,
}

class NotificationUtils {
  static NotificationType getNotificationType(String typeString) {
    switch (typeString) {
      case 'App\\Notifications\\UserCommentedATask':
        return NotificationType.taskComment;
      case 'App\\Notifications\\TaskCompleted':
        return NotificationType.taskCompleted;
      case 'App\\Notifications\\Follow':
        return NotificationType.follow;
      case 'App\\Notifications\\TaskReminder':
        return NotificationType.taskReminder;
      default:
        return NotificationType.unknown;
    }
  }

  static String getNotificationRelatedTypeKey(
      notification_model.Notification notification) {
    switch (notification.type) {
      case 'App\\Notifications\\UserCommentedATask':
        return 'task';
      case 'App\\Notifications\\TaskCompleted':
        return 'task';
      case 'App\\Notifications\\TaskReminder':
        return 'task';
      default:
        return '';
    }
  }

  static String getNotificationMessage(
      notification_model.Notification notification) {
    final type = getNotificationType(notification.type);

    switch (type) {
      case NotificationType.taskComment:
        return 'Commented on your task';
      case NotificationType.taskCompleted:
        return 'Completed a task';
      case NotificationType.follow:
        return 'Followed you';
      case NotificationType.taskReminder:
        return 'Task reminder';
      case NotificationType.unknown:
        return 'New activity';
    }
  }

  static IconData getNotificationIcon(
      notification_model.Notification notification) {
    final type = getNotificationType(notification.type);

    switch (type) {
      case NotificationType.taskComment:
        return Icons.comment;
      case NotificationType.taskCompleted:
        return Icons.check_circle;
      case NotificationType.follow:
        return Icons.person;
      case NotificationType.taskReminder:
        return Icons.alarm;
      case NotificationType.unknown:
        return Icons.notifications;
    }
  }

  static void handleNotificationTap(
    BuildContext context,
    notification_model.Notification notification,
  ) {
    final type = getNotificationType(notification.type);

    switch (type) {
      case NotificationType.taskComment:
        if (notification.relatedId != null) {
          context.pushNamed('taskDetail',
              pathParameters: {'taskId': notification.relatedId.toString()});
        }
        break;
      case NotificationType.taskCompleted:
        if (notification.relatedId != null) {
          context.pushNamed('taskDetail',
              pathParameters: {'taskId': notification.relatedId.toString()});
        }
        break;
      case NotificationType.follow:
        if (notification.relatedId != null) {
          Navigator.pushNamed(context, '/users/detail',
              arguments: {'userId': notification.relatedId});
        }
        break;
      case NotificationType.taskReminder:
        if (notification.relatedId != null) {
          context.pushNamed('taskDetail',
              pathParameters: {'taskId': notification.relatedId.toString()});
        }
        break;
      case NotificationType.unknown:
        // Default behavior
        break;
    }
  }
}
