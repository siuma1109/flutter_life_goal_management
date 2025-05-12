import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/project.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/project_service.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_list_widget.dart';

class ProjectScreen extends StatefulWidget {
  final int projectId;
  final User user;
  const ProjectScreen({
    super.key,
    required this.projectId,
    required this.user,
  });

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Project? _project;
  List<Task> _tasks = [];
  StreamSubscription? _taskChangedSubscription;
  int _page = 1;
  bool _hasMoreData = true;
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProject();
    _loadTasks();

    // Listen for task changes
    _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
      _loadTasks();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMoreData) {
        _loadTasks();
      }
    });
  }

  @override
  void dispose() {
    _taskChangedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProject() async {
    final project = await ProjectService().getProject(widget.projectId);

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

  Future<void> _refreshTasks() async {
    setState(() {
      _page = 1;
      _hasMoreData = true;
      _tasks = [];
    });
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (!_hasMoreData) return;
    setState(() {
      _isLoading = true;
    });
    final tasks = await TaskService().getTasksByProjectId(
      widget.projectId,
      _page,
      userId: widget.user.id,
    );
    if (mounted) {
      if (tasks.isEmpty) {
        setState(() {
          _hasMoreData = false;
        });
      } else {
        setState(() {
          _tasks.addAll(tasks.where((t) => !_tasks.any((tt) => tt.id == t.id)));
          _page++;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    if (_project?.userId != AuthService().getLoggedInUser()?.id) {
      return;
    }
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
                if (widget.projectId != null) {
                  await ProjectService().deleteProject(widget.projectId!);

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
          if (_project?.userId == AuthService().getLoggedInUser()?.id)
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
        onRefresh: _refreshTasks,
        child: TaskListWidget(
          tasks: _tasks,
          scrollController: _scrollController,
        ),
      ),
    );
  }
}
