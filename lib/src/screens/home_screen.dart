import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/feed.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
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
  List<Task> _tasks = [];
  int taskPage = 1;
  bool taskHasMoreData = true;
  bool taskIsLoading = false;
  StreamSubscription<void>? taskChangedSubscription;

  List<Feed> _feeds = [];
  int feedPage = 1;
  bool feedHasMoreData = true;
  bool feedIsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadFeeds();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.5 &&
          !feedIsLoading &&
          feedHasMoreData) {
        _loadFeeds();
      }
    });

    taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((task) {
      if (task != null) {
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            _tasks[index] = task;
          } else {
            _tasks.add(task);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scrollController,
          children: [
            TodayTasksWidget(
              tasks: _tasks,
              loadTasks: _loadTasks,
            ),
            FeedListWidget(
              feeds: _feeds,
            ),
          ],
        ),
      ),
      floatingActionButton: const AddTaskFloatingButtonWidget(),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      taskPage = 1;
      _tasks = [];
      taskHasMoreData = true;
      taskIsLoading = false;
      feedPage = 1;
      _feeds = [];
      feedHasMoreData = true;
      feedIsLoading = false;
    });
    await Future.wait([_loadTasks(), _loadFeeds()]);
  }

  Future<void> _loadTasks() async {
    if (taskIsLoading) return;

    setState(() {
      taskIsLoading = true;
    });

    try {
      final tasks = await TaskService().getTodayTasks(taskPage);
      if (tasks.isEmpty) {
        taskHasMoreData = false;
      } else {
        setState(() {
          _tasks.addAll(tasks.where((t) => !_tasks.any((tt) => tt.id == t.id)));
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
}
