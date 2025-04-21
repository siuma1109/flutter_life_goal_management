import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
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
  StreamSubscription? _taskChangedSubscription;

  @override
  void initState() {
    super.initState();
    _loadTasks();

    // Listen for task changes
    _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
      _loadTasks();
    });
  }

  @override
  void dispose() {
    _taskChangedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await TaskService().getInboxTasks();
      setState(() {
        _tasks = tasks;
      });
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
        onRefresh: _loadTasks,
        child: _tasks.isEmpty
            ? const Center(child: Text("No tasks in inbox"))
            : TaskListWidget(
                tasks: _tasks,
              ),
      ),
      floatingActionButton: const AddTaskFloatingButtonWidget(),
    );
  }
}
