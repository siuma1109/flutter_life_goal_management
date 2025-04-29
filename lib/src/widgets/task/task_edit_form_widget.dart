import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
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
  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    print('task: ${_task.toJson()}');
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: ViewTaskWidget(
              task: _task,
              onRefresh: widget.onRefresh,
            ),
          );
        },
      ),
    );
  }
}
