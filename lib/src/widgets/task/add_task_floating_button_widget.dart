import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_add_form_widget.dart';

class AddTaskFloatingButtonWidget extends StatefulWidget {
  const AddTaskFloatingButtonWidget({super.key});

  @override
  State<AddTaskFloatingButtonWidget> createState() =>
      _AddTaskFloatingButtonWidgetState();
}

class _AddTaskFloatingButtonWidgetState
    extends State<AddTaskFloatingButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        var result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => TaskAddFormWidget(),
        );

        if (result == true) {
          // Broadcast task changes to all listeners
          TaskBroadcast().notifyTasksChanged();
        }
      },
      child: const Icon(Icons.add),
    );
  }
}
