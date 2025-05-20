import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
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
        TaskBroadcast().taskChangedStream.listen((Task? task) async {
      //print('task: ${task?.toJson()}');
      if (task != null &&
          task.id != null &&
          task.id != 0 &&
          task.parentId == null &&
          !_tasks.any((t) => t.id == task.id)) {
        // Ensure the task has proper user information
        final currentUser = await AuthService().getLoggedInUserAsync();
        // If task doesn't have user info, set the current user as the owner
        if (task.user == null && currentUser != null) {
          task.user = currentUser;
        }

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
        } else if (parentIndex >= 0) {
          setState(() {
            _tasks[parentIndex].subTasks.insert(0, task);
          });
        }
      }
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
            : Stack(
                children: [
                  TaskListWidget(
                    tasks: _tasks,
                    scrollController: _scrollController,
                    isLoading: _isLoading,
                  ),
                  if (_isLoading)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.8),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: const AddTaskFloatingButtonWidget(),
    );
  }
}
