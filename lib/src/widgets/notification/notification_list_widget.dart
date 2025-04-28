import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/notification.dart'
    as notification_model;
import 'package:flutter_life_goal_management/src/widgets/notification/notification_list_item_widget.dart';
import 'package:flutter_life_goal_management/src/utils/notification_utils.dart';

class NotificationListWidget extends StatelessWidget {
  final List<notification_model.Notification> notifications;
  final void Function(notification_model.Notification)? onNotificationTap;
  final ScrollController? controller;
  final bool isLoading;
  final bool hasMoreData;
  final VoidCallback? onLoadMore;

  const NotificationListWidget({
    super.key,
    required this.notifications,
    this.onNotificationTap,
    this.controller,
    this.isLoading = false,
    this.hasMoreData = false,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty && !isLoading) {
      return _buildEmptyState(context);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (hasMoreData &&
            !isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: ListView.builder(
        controller: controller,
        itemCount: notifications.length + (isLoading ? 1 : 0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final notification = notifications[index];
          return NotificationListItem(
            notification: notification,
            onTap: () {
              if (onNotificationTap != null) {
                onNotificationTap!(notification);
              } else {
                NotificationUtils.handleNotificationTap(context, notification);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New notifications will be displayed here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
