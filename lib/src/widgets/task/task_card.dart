import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_edit_form_widget.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onCompleted;
  final Function(Task?)? onEdited;

  const TaskCard({
    required this.task,
    required this.onCompleted,
    this.onEdited,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => TaskEditFormWidget(
            task: task,
            onRefresh: (Task? task) {
              if (task != null) {
                onEdited?.call(task);
              }
            },
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Checkbox(
                    side: BorderSide(
                      color: TaskService().getPriorityColor(task.priority),
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(
                        color: TaskService().getPriorityColor(task.priority),
                        width: 2.0,
                      ),
                    ),
                    activeColor: TaskService().getPriorityColor(task.priority),
                    value: task.isChecked,
                    onChanged: (_) {
                      onCompleted();
                      _updateTask(task);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Sub Tasks",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "${task.subTasks?.where((subTask) => subTask.isChecked).length ?? 0}/${task.subTasks?.length ?? 0}",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateTask(Task task) async {
    //print("task: ${task.toJson()}");
    await TaskService().updateTask(task);
  }
}
