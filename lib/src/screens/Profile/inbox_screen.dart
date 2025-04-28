import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_list_widget.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<Task> _tasks = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMoreData = true;
  StreamSubscription? _taskChangedSubscription;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTasks();

    // Listen for task changes
    _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
      _loadTasks();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMoreData) {
        _loadTasks();
      }
    });
  }

  @override
  void dispose() {
    _taskChangedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _page = 1;
      _hasMoreData = true;
      _tasks = [];
    });
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_hasMoreData) {
        final tasks = await TaskService().getInboxTasks(_page);
        if (tasks.isEmpty) {
          setState(() {
            _hasMoreData = false;
          });
        } else {
          setState(() {
            _tasks
                .addAll(tasks.where((t) => !_tasks.any((tt) => tt.id == t.id)));
            _page++;
          });
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inbox"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: _tasks.isEmpty
            ? const Center(child: Text("No tasks in inbox"))
            : TaskListWidget(
                tasks: _tasks,
                scrollController: _scrollController,
              ),
      ),
      floatingActionButton: const AddTaskFloatingButtonWidget(),
    );
  }
}
