import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../services/database_helper.dart';

class TaskListWidget extends StatefulWidget {
  final List<Task> tasks;
  final Function onRefresh;

  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.onRefresh,
  });

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return widget.tasks.isEmpty
        ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 100),
              Center(
                child: Text('No tasks found. Pull down to refresh.'),
              ),
            ],
          )
        : ListView.builder(
            itemCount: widget.tasks.length,
            itemBuilder: (context, index) {
              final task = widget.tasks[index];
              return Container(
                decoration: BoxDecoration(
                  border: index < widget.tasks.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: Colors.black12,
                            width: 1.0,
                          ),
                        )
                      : null,
                ),
                child: GestureDetector(
                  onTap: () async {
                    _taskService.showTaskEditForm(
                        context, task, () => widget.onRefresh());
                  },
                  child: ListTile(
                    leading: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: task.isChecked,
                        side: BorderSide(
                          color: _taskService.getPriorityColor(task.priority),
                          width: 2.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(
                            color: _taskService.getPriorityColor(task.priority),
                            width: 2.0,
                          ),
                        ),
                        activeColor:
                            _taskService.getPriorityColor(task.priority),
                        onChanged: (bool? newValue) {
                          setState(() {
                            task.isChecked = !task.isChecked;
                            _databaseHelper.updateTask(task.toMap());
                            widget.onRefresh();
                          });
                        },
                      ),
                    ),
                    title: Text(task.title),
                    subtitle: (task.description != null &&
                            task.description != '')
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.description!),
                              if (task.dueDate != null)
                                Text(task.dueDate!.toString().split(' ')[0]),
                            ],
                          )
                        : null,
                  ),
                ),
              );
            },
          );
  }
}
