import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_add_form_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_edit_form_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_row_widget.dart';

class SubTaskListWidget extends StatefulWidget {
  final Task task;
  final Function? onRefresh;

  const SubTaskListWidget({
    super.key,
    required this.task,
    this.onRefresh,
  });

  @override
  State<SubTaskListWidget> createState() => _SubTaskListWidgetState();
}

class _SubTaskListWidgetState extends State<SubTaskListWidget> {
  late Task _task;
  late User _user;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _user = AuthService().getLoggedInUser()!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Subtasks section
        if (_task.subTasks.isNotEmpty) _buildSubtasksSection(),

        // Add subtask button
        if (_task.userId == _user.id) _buildAddSubtaskButton(),
      ],
    );
  }

  Widget _buildSubtasksSection() {
    final completeSubTasks =
        _task.subTasks.where((task) => task.isChecked).length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TaskRowWidget(
          icon: const Icon(Icons.list),
          content: Text(
            "Sub Tasks ($completeSubTasks/${_task.subTasks.length})",
            style: const TextStyle(fontSize: 16),
          ),
        ),
        ..._task.subTasks
            .asMap()
            .map((index, subTask) => MapEntry(
                index,
                TaskRowWidget(
                  icon: _task.userId == _user.id
                      ? Checkbox(
                          activeColor:
                              TaskService().getPriorityColor(subTask.priority),
                          side: BorderSide(
                            color: TaskService()
                                .getPriorityColor(subTask.priority),
                            width: 2.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(
                              color: TaskService()
                                  .getPriorityColor(subTask.priority),
                              width: 2.0,
                            ),
                          ),
                          value: subTask.isChecked,
                          onChanged: (bool? newValue) {
                            subTask.isChecked = !subTask.isChecked;
                            setState(() {
                              TaskService().updateTask(subTask);
                            });
                            widget.onRefresh?.call(_task);
                          },
                        )
                      : const SizedBox.shrink(),
                  content: GestureDetector(
                      onTap: () =>
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => TaskEditFormWidget(
                                task: subTask,
                                onRefresh: (returnSubTask) {
                                  if (returnSubTask == null) {
                                    setState(() {
                                      _task.subTasks.removeAt(index);
                                    });
                                  } else {
                                    setState(() {
                                      _task.subTasks[index] = returnSubTask;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subTask.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (subTask.description != null &&
                              subTask.description != '')
                            Text(
                              subTask.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          if (subTask.startDate != null)
                            Text(
                                'Start Date: ${subTask.startDate!.toString().split(' ')[0]}'),
                          if (subTask.endDate != null)
                            Text(
                              'End Date: ${subTask.endDate!.toString().split(' ')[0]}',
                            ),
                          Text(
                            'Priority: ${subTask.priority}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          if (subTask.subTasks.isNotEmpty)
                            Text(
                              'Sub Tasks: ${subTask.subTasks.where((task) => task.isChecked).length}/${subTask.subTasks.length}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      )),
                )))
            .values,
      ],
    );
  }

  Widget _buildAddSubtaskButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => TaskAddFormWidget(
              task: Task(
                parentId: _task.id,
                title: "",
                isChecked: false,
                userId: _user.id!,
                projectId: widget.task.projectId,
                subTasks: [],
                priority: 4,
              ),
              onRefresh: (subTask) => {
                setState(() {
                  _task.subTasks.add(subTask);
                }),
                if (_task.id != null) TaskService().insertTask(subTask),
              },
              isParentTask: false,
              title: "Add Sub Task",
            ),
          ),
        );
      },
      child: TaskRowWidget(
        icon: Icon(
          Icons.add,
          color: Colors.redAccent,
        ),
        content: Text(
          "Add sub task",
          style: TextStyle(
            fontSize: 16,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
