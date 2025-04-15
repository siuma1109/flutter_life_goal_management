import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class TaskListWidget extends StatefulWidget {
  final List<Task> tasks;

  const TaskListWidget({
    super.key,
    required this.tasks,
  });

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  final TaskService _taskService = TaskService();
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks;
  }

  @override
  Widget build(BuildContext context) {
    return _tasks.isEmpty
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
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final _task = _tasks[index];
              return Container(
                decoration: BoxDecoration(
                  border: index < _tasks.length - 1
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
                    _taskService.showTaskEditForm(context, _task, false,
                        (task) {
                      setState(() {
                        _tasks[index] = task;
                      });
                    });
                  },
                  child: ListTile(
                    leading: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: _task.isChecked,
                        side: BorderSide(
                          color: _taskService.getPriorityColor(_task.priority),
                          width: 2.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(
                            color:
                                _taskService.getPriorityColor(_task.priority),
                            width: 2.0,
                          ),
                        ),
                        activeColor:
                            _taskService.getPriorityColor(_task.priority),
                        onChanged: (bool? newValue) {
                          setState(() {
                            _task.isChecked = !_task.isChecked;
                            _taskService.updateTask(_task.toMap());
                          });
                        },
                      ),
                    ),
                    title: Text(_task.title),
                    subtitle: (_task.description != null &&
                            _task.description != '')
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_task.description!),
                              if (_task.dueDate != null)
                                Text(_task.dueDate!.toString().split(' ')[0]),
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
