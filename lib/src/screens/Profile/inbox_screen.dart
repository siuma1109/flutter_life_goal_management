import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_list_widget.dart';

class InboxScreen extends StatefulWidget {
  final User user;
  const InboxScreen({super.key, required this.user});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<Task> _tasks = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMoreData = true;
  StreamSubscription? _taskChangedSubscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTasks();

    // Listen for task changes
    _taskChangedSubscription =
        TaskBroadcast().taskChangedStream.listen((Task? task) {
      //print('task: ${task?.toJson()}');
      if (task != null &&
          task.id != null &&
          task.id != 0 &&
          task.parentId == null &&
          !_tasks.any((t) => t.id == task.id)) {
        setState(() {
          _tasks.insert(0, task);
        });
      }

      if (task != null && task.parentId != null) {
        final parentIndex = _tasks.indexWhere((t) => t.id == task.parentId);
        if (parentIndex != -1) {
          setState(() {
            _tasks[parentIndex].subTasks[parentIndex] = task;
          });
        } else {
          setState(() {
            _tasks[parentIndex].subTasks.insert(0, task);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _taskChangedSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _page = 1;
      _hasMoreData = true;
      _tasks.clear();
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
        final tasks = await TaskService().getInboxTasks(
          _page,
          userId: widget.user.id,
        );
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
    } catch (e) {
      // 处理错误
      print('Error loading tasks: $e');
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
