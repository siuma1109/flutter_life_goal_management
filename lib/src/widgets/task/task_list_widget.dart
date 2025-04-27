import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_card.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_edit_form_widget.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class TaskListWidget extends StatefulWidget {
  final List<Task> tasks;
  final ScrollController? scrollController;

  const TaskListWidget({
    super.key,
    required this.tasks,
    this.scrollController,
  });

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  final TaskService _taskService = TaskService();

  void _refreshTasks(Task? task) {
    // Broadcast the change
    TaskBroadcast().notifyTasksChanged(task);
  }

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
            controller: widget.scrollController,
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
                child: TaskCard(
                  task: task,
                  onEdited: (Task? updatedTask) {
                    if (updatedTask != null) {
                      setState(() {
                        widget.tasks[index] = updatedTask;
                      });
                    }
                  },
                ),
              );
            },
          );
  }
}
