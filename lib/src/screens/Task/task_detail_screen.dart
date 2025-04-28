import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_card.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _isLoading = true;
  Task? _task;
  String? _error;
  StreamSubscription? _taskChangedSubscription;

  @override
  void initState() {
    super.initState();
    _loadTask();
    _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
      _loadTask();
    });
  }

  @override
  void dispose() {
    _taskChangedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final task = await TaskService().getTaskById(widget.taskId);

      if (task == null) {
        setState(() {
          _error = 'Task not found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _task = task;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Load failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTask,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_task == null) {
      return const Center(child: Text('没有数据'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          TaskCard(
            task: _task!,
            showUser: true,
            onEdited: (updatedTask) {
              if (updatedTask != null) {
                setState(() {
                  _task = updatedTask;
                });
              }
            },
          ),
          // 这里可以添加更多关于任务的详细信息，例如评论列表、相关任务等
        ],
      ),
    );
  }
}
