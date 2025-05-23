import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/notification_broadcast.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/feed.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/screens/Home/home_shimmer_loading_widget.dart';
import 'package:flutter_life_goal_management/src/screens/Notification/notification_screen.dart';
import 'package:flutter_life_goal_management/src/services/notification_service.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/services/feed_service.dart';
import 'package:flutter_life_goal_management/src/widgets/feed/feed_list_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/home/today_tasks_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tasksScrollController =
      ScrollController(keepScrollOffset: true);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool isRefreshing = false;

  List<Task> _tasks = [];
  int taskPage = 1;
  bool taskHasMoreData = true;
  bool taskIsLoading = false;
  StreamSubscription<void>? taskChangedSubscription;
  StreamSubscription<void>? projectChangedSubscription;

  List<Feed> _feeds = [];
  int feedPage = 1;
  bool feedHasMoreData = true;
  bool feedIsLoading = false;
  bool _isInitialLoading = true;
  StreamSubscription<void>? notificationUnreadCountSubscription;
  int _notificationUnreadCount = 0;
  int _chatCount = 6;

  @override
  void initState() {
    super.initState();
    _loadNotificationsUnreadCount();

    notificationUnreadCountSubscription =
        NotificationBroadcast().notificationUnreadCountStream.listen((_) {
      _loadNotificationsUnreadCount();
    });

    projectChangedSubscription =
        TaskBroadcast().projectChangedStream.listen((_) {
      _refreshFeeds();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.5 &&
          !feedIsLoading &&
          feedHasMoreData) {
        _loadFeeds();
      }
    });

    _tasksScrollController.addListener(() {
      if (_tasksScrollController.position.pixels >=
              _tasksScrollController.position.maxScrollExtent * 0.5 &&
          !taskIsLoading &&
          taskHasMoreData) {
        _loadTasks();
      }
    });
    DateTime today = DateTime.now();
    DateTime startOfDate =
        DateTime(today.year, today.month, today.day, 0, 0, 0);
    DateTime endOfDate =
        DateTime(today.year, today.month, today.day, 23, 59, 59);
    taskChangedSubscription =
        TaskBroadcast().taskChangedStream.listen((Task? task) {
      setState(() {
        isRefreshing = true;
      });
      print('task changed: ${task?.toJson()}');
      if (task?.isDeleted == true) {
        final index = _tasks.indexWhere((t) => t.id == task?.id);
        if (index != -1) {
          _tasks.removeAt(index);
        }
      }

      if (task != null &&
          task.id != null &&
          task.id != 0 &&
          task.isDeleted == false) {
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            if (task.parentId == null) {
              print('updated task: ${task.toJson()}');
              print('index: $index');
              print('tasks Index: ${_tasks[index].toJson()}');
              _tasks[index] = task;
            } else {
              final subTaskIndex =
                  _tasks[index].subTasks.indexWhere((t) => t.id == task.id);
              if (subTaskIndex != -1) {
                _tasks[index].subTasks[subTaskIndex] = task;
              }
            }
          } else {
            bool isForToday = false;
            if (task.startDate != null &&
                task.endDate != null &&
                task.startDate!.isBefore(endOfDate) &&
                task.endDate!.isAfter(startOfDate)) {
              isForToday = true;
            }

            if (isForToday) {
              if (task.parentId != null) {
                final parentIndex =
                    _tasks.indexWhere((t) => t.id == task.parentId);
                if (parentIndex != -1) {
                  final subTaskIndex = _tasks[parentIndex]
                      .subTasks
                      .indexWhere((t) => t.id == task.id);
                  if (subTaskIndex != -1) {
                    _tasks[parentIndex].subTasks[subTaskIndex] = task;
                  } else {
                    _tasks[parentIndex].subTasks.add(task);
                  }
                }
              } else if (!_tasks.any((t) => t.id == task.id)) {
                _tasks = [task, ..._tasks];
              }
            }
          }
        });
      }

      _refreshFeeds();

      setState(() {
        isRefreshing = false;
      });
    });

    // Trigger the loading indicator programmatically after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications),
                if (_notificationUnreadCount > 0)
                  Positioned(
                    top: -12,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _notificationUnreadCount.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          // todo: implment chat feature
          if (false)
            IconButton(
              icon: Stack(clipBehavior: Clip.none, children: [
                Icon(Icons.chat),
                if (_chatCount > 0)
                  Positioned(
                    top: -12,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _chatCount.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ]),
              onPressed: () {},
            ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: _isInitialLoading && _tasks.isEmpty && _feeds.isEmpty
            ? const HomeShimmerLoadingWidget()
            : ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  TodayTasksWidget(
                    tasks: _tasks,
                    loadTasks: _loadTasks,
                    isRefreshing: isRefreshing,
                    isLoading: taskIsLoading,
                    scrollController: _tasksScrollController,
                  ),
                  FeedListWidget(
                    feeds: _feeds,
                    isRefreshing: isRefreshing,
                    isLoading: feedIsLoading,
                  ),
                ],
              ),
      ),
      floatingActionButton: const AddTaskFloatingButtonWidget(),
    );
  }

  Future<void> _refresh() async {
    if (isRefreshing) return;
    setState(() {
      isRefreshing = true;
    });
    await Future.wait([_refreshTasks(), _refreshFeeds()]);
    setState(() {
      _isInitialLoading = false;
      isRefreshing = false;
    });
  }

  Future<void> _refreshTasks() async {
    setState(() {
      taskPage = 1;
      _tasks = [];
      taskHasMoreData = true;
      taskIsLoading = false;
    });
    await _loadTasks();
  }

  Future<void> _refreshFeeds() async {
    setState(() {
      feedPage = 1;
      _feeds = [];
      feedHasMoreData = true;
      feedIsLoading = false;
    });
    await _loadFeeds();
  }

  Future<void> _loadTasks() async {
    if (taskIsLoading) return;
    if (!taskHasMoreData) return;

    setState(() {
      taskIsLoading = true;
    });
    try {
      final tasks = await TaskService().getTodayTasks(taskPage);

      if (tasks.isEmpty) {
        setState(() {
          taskHasMoreData = false;
        });
      } else {
        setState(() {
          final tasksToAdd =
              tasks.where((t) => !_tasks.any((tt) => tt.id == t.id)).toList();

          _tasks.addAll(tasksToAdd);
          taskPage++;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        taskIsLoading = false;
      });
    }
  }

  Future<void> _loadFeeds() async {
    if (feedIsLoading) return;
    setState(() {
      feedIsLoading = true;
    });
    try {
      final feeds = await FeedService().getFeeds(feedPage);
      if (feeds.isEmpty) {
        setState(() {
          feedHasMoreData = false;
        });
      } else {
        setState(() {
          _feeds.addAll(feeds.where((f) => !_feeds.any((ff) => ff.id == f.id)));
          feedPage++;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        feedIsLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tasksScrollController.dispose();
    taskChangedSubscription?.cancel();
    projectChangedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadNotificationsUnreadCount() async {
    final notificationsUnreadCount =
        await NotificationService().getNotificationsUnreadCount();
    setState(() {
      _notificationUnreadCount = notificationsUnreadCount;
    });
  }
}
