import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';

class SubTasksWidget extends StatefulWidget {
  final Task task;
  final bool isSubTask;
  const SubTasksWidget({
    super.key,
    required this.task,
    this.isSubTask = false,
  });

  @override
  State<SubTasksWidget> createState() => _StateSubTasksWidget();
}

class _StateSubTasksWidget extends State<SubTasksWidget> {
  late Task _task;
  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  void didUpdateWidget(SubTasksWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) {
      setState(() {
        _task = widget.task;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_task.subTasks.isNotEmpty) _buildSubtasksSection(),
      ],
    );
  }

  Widget _buildTaskRow({required Widget icon, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 50,
            child: icon,
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection() {
    final completeSubTasks =
        _task.subTasks.where((task) => task.isChecked).length;
    return Column(
      children: [
        _buildTaskRow(
          icon: const Icon(Icons.list),
          content: Text(
            "Sub Tasks ($completeSubTasks/${_task.subTasks.length})",
            style: const TextStyle(fontSize: 16),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _task.subTasks.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final task = _task.subTasks[index];
            return Container(
              decoration: BoxDecoration(
                border: index < _task.subTasks.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: Colors.black12,
                          width: 1.0,
                        ),
                      )
                    : null,
              ),
              child: GestureDetector(
                onTap: () => TaskService().showTaskEditForm(
                    context, task, widget.isSubTask, (returnTask) {
                  setState(() {
                    _task.subTasks[index] = returnTask;
                  });
                }),
                child: ListTile(
                  leading: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: task.isChecked,
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
                      activeColor:
                          TaskService().getPriorityColor(task.priority),
                      onChanged: (bool? newValue) {
                        task.isChecked = !task.isChecked;
                        setState(() {
                          _task.subTasks[index] = task;
                          TaskService().updateTask(task.toMap());
                        });
                      },
                    ),
                  ),
                  title: Text(task.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (task.description != null && task.description != '')
                        Text(task.description!),
                      if (task.dueDate != null)
                        Text('Due: ${task.dueDate!.toString().split(' ')[0]}'),
                      Text('Priority: ${task.priority}'),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
