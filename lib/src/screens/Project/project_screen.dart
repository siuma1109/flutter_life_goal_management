import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/project.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/project_service.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_list_widget.dart';

class ProjectScreen extends StatefulWidget {
  final Project project;
  const ProjectScreen({super.key, required this.project});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Project? _project;
  List<Task> _tasks = [];
  StreamSubscription? _taskChangedSubscription;

  @override
  void initState() {
    super.initState();
    _loadProject();
    _loadTasks();

    // Listen for task changes
    _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
      _loadTasks();
    });
  }

  @override
  void dispose() {
    _taskChangedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProject() async {
    final project = await ProjectService().getProject(widget.project.id ?? 0);

    if (mounted) {
      if (project == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project not found')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }

      setState(() {
        _project = project;
      });
    }
  }

  Future<void> _loadTasks() async {
    final tasks =
        await TaskService().getTasksByProjectId(widget.project.id ?? 0);
    if (mounted) {
      setState(() {
        _tasks = tasks;
      });
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: const Text('Are you sure you want to delete this project?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (widget.project.id != null) {
                  await ProjectService().deleteProject(widget.project.id!);

                  // Broadcast project change
                  TaskBroadcast().notifyProjectChanged();

                  // Close the dialog using the dialog context
                  Navigator.of(dialogContext).pop();

                  // Now pop back to the previous screen using the main context
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project?.name ?? 'Project'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmationDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Project'),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: TaskListWidget(
          tasks: _tasks,
        ),
      ),
    );
  }
}
