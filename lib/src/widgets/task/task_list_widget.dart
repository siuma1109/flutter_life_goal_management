import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_card.dart';
import '../../models/task.dart';

class TaskListWidget extends StatefulWidget {
  final List<Task> tasks;
  final ScrollController? scrollController;
  final bool showUser;

  const TaskListWidget({
    super.key,
    required this.tasks,
    this.scrollController,
    this.showUser = false,
  });

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.tasks.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text('No tasks',
                    style: Theme.of(context).textTheme.headlineLarge),
              ],
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: widget.scrollController == null
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            controller: widget.scrollController,
            itemCount: widget.tasks.length,
            itemBuilder: (context, index) {
              final task = widget.tasks[index];
              //task.title = '$index: ${task.title} ${task.id}';
              return Container(
                key: Key(task.id.toString()),
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
                  showUser: widget.showUser,
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
