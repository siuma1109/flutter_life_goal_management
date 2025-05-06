import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_widget.dart';

class TaskAddFormWidget extends StatefulWidget {
  final Task? task;
  final bool isParentTask;
  final Function? onRefresh;
  final String title;
  const TaskAddFormWidget({
    super.key,
    this.task,
    this.isParentTask = true,
    this.onRefresh,
    this.title = 'Add Task',
  });

  @override
  State<TaskAddFormWidget> createState() => _TaskAddFormWidgetState();
}

class _TaskAddFormWidgetState extends State<TaskAddFormWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AddTaskWidget(
      task: widget.task,
      onRefresh: widget.onRefresh,
      isParentTask: widget.isParentTask,
      title: widget.title,
    );
  }
}
