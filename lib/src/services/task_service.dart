import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task/view_task_widget.dart';

class TaskService {
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Future<void> showTaskEditForm(
      BuildContext context, Task task, VoidCallback onRefresh) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * (2 / 3),
            child: ViewTaskWidget(
              task: task,
              onRefresh: onRefresh,
            ),
          ),
        );
      },
    );

    if (result == true) {
      onRefresh();
    }
  }
}
