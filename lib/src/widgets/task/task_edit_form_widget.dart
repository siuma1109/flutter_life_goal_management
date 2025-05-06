import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/view_task_widget.dart';

class TaskEditFormWidget extends StatefulWidget {
  final Task task;
  final Function(Task?) onRefresh;
  const TaskEditFormWidget({
    super.key,
    required this.task,
    required this.onRefresh,
  });

  @override
  State<TaskEditFormWidget> createState() => _TaskEditFormWidgetState();
}

class _TaskEditFormWidgetState extends State<TaskEditFormWidget> {
  late Task _task;
  late String _title;
  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _title = widget.task.userId == AuthService().getLoggedInUser()?.id
        ? 'Edit Task'
        : 'View Task';
  }

  @override
  Widget build(BuildContext context) {
    //print('task: ${_task.toJson()}');
    return ViewTaskWidget(
      title: _title,
      task: _task,
      onRefresh: widget.onRefresh,
    );
  }
}
