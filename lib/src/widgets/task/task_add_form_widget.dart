import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/widgets/draggable_sheet_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_widget.dart';
import 'package:go_router/go_router.dart';

class TaskAddFormWidget extends StatefulWidget {
  final Task? task;
  final bool isParentTask;
  final Function? onRefresh;
  final User? user;
  const TaskAddFormWidget({
    super.key,
    this.task,
    this.isParentTask = true,
    this.onRefresh,
    this.user,
  });

  @override
  State<TaskAddFormWidget> createState() => _TaskAddFormWidgetState();
}

class _TaskAddFormWidgetState extends State<TaskAddFormWidget> {
  User? _user;
  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableSheetWidget(
        child: AddTaskWidget(
          task: widget.task,
          user: _user!,
          onRefresh: widget.onRefresh,
          isParentTask: widget.isParentTask,
        ),
      ),
    );
  }
}
