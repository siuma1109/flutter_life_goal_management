import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/widgets/draggable_sheet_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_widget.dart';

class TaskAddFormWidget extends StatefulWidget {
  final Task? task;
  final bool isParentTask;
  final Function? onRefresh;
  const TaskAddFormWidget({
    super.key,
    this.task,
    this.isParentTask = true,
    this.onRefresh,
  });

  @override
  State<TaskAddFormWidget> createState() => _TaskAddFormWidgetState();
}

class _TaskAddFormWidgetState extends State<TaskAddFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableSheetWidget(
        child: AddTaskWidget(
          task: widget.task,
          onRefresh: widget.onRefresh,
          isParentTask: widget.isParentTask,
        ),
      ),
    );
  }
}
