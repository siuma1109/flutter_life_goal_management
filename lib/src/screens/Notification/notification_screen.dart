import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/notification.dart'
    as notification_model;
import 'package:flutter_life_goal_management/src/services/notification_service.dart';
import 'package:flutter_life_goal_management/src/widgets/notification/notification_list_widget.dart';
import 'package:flutter_life_goal_management/src/utils/notification_utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<notification_model.Notification> _notifications = [];
  int _page = 1;
  bool _hasMoreData = true;
  bool _isLoading = false;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await NotificationService().getNotifications(_page);

      setState(() {
        if (notifications.isEmpty) {
          _hasMoreData = false;
        } else {
          _notifications = [..._notifications, ...notifications];
          _page++;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Load notifications failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _refreshNotifications() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _page = 1;
      _hasMoreData = true;
    });

    try {
      final notifications = await NotificationService().getNotifications(1);

      setState(() {
        _notifications = notifications;
        _page = 2;
        _hasMoreData = notifications.isNotEmpty;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Refresh notifications failed: ${e.toString()}')),
      );
    }
  }

  void _handleNotificationTap(notification_model.Notification notification) {
    NotificationUtils.handleNotificationTap(context, notification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshNotifications,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: NotificationListWidget(
          notifications: _notifications,
          controller: _scrollController,
          isLoading: _isLoading,
          hasMoreData: _hasMoreData,
          onLoadMore: _loadNotifications,
          onNotificationTap: _handleNotificationTap,
        ),
      ),
    );
  }
}
