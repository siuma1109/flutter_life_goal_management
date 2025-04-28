import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/services/notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_life_goal_management/src/models/notification.dart'
    as notification_model;
import 'package:flutter_life_goal_management/src/utils/notification_utils.dart';

class NotificationListItem extends StatefulWidget {
  final notification_model.Notification notification;
  final VoidCallback? onTap;

  const NotificationListItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  State<NotificationListItem> createState() => _NotificationListItemState();
}

class _NotificationListItemState extends State<NotificationListItem> {
  notification_model.Notification? _notification;

  @override
  void initState() {
    super.initState();
    _notification = widget.notification;
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTime = timeago.format(_notification!.createdAt);

    final IconData typeIcon =
        NotificationUtils.getNotificationIcon(_notification!);

    return InkWell(
      onTap: () {
        if (!_notification!.isRead) {
          NotificationService().markNotificationAsRead(_notification!.id);
          setState(() {
            _notification!.readAt = DateTime.now();
          });
        }
        print('relatedId: ${_notification!.relatedId}');
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          NotificationUtils.handleNotificationTap(context, _notification!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _notification!.isRead
              ? Colors.transparent
              : Colors.blue.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeadingWidget(context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(context),
                  const SizedBox(height: 4),
                  if (_notification!.content != null) ...[
                    Text(
                      _notification!.content!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              typeIcon,
              color: _notification!.isRead ? Colors.grey : Colors.blue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingWidget(BuildContext context) {
    if (_notification!.userAvatar != null) {
      return Row(
        children: [
          if (!_notification!.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          CircleAvatar(
            backgroundImage: NetworkImage(_notification!.userAvatar!),
            radius: 20,
            backgroundColor: Colors.grey[300],
          ),
        ],
      );
    }

    return Row(
      children: [
        if (!_notification!.isRead)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        CircleAvatar(
          radius: 20,
          backgroundColor:
              _notification!.isRead ? Colors.grey[200] : Colors.blue[100],
          child: Icon(
            NotificationUtils.getNotificationIcon(_notification!),
            color: _notification!.isRead ? Colors.grey[700] : Colors.blue[700],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          if (_notification!.username != null)
            TextSpan(
              text: _notification!.username!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          TextSpan(
            text: _notification!.username != null ? ' ' : '',
            style: DefaultTextStyle.of(context).style,
          ),
          TextSpan(
            text: NotificationUtils.getNotificationMessage(_notification!),
            style: DefaultTextStyle.of(context).style.copyWith(
                  fontSize: 15,
                ),
          ),
        ],
      ),
    );
  }
}
