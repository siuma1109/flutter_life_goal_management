import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_widget.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  final String title;

  const ProfileScreen({super.key, required this.title});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Task> _tasks = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _databaseHelper.getAllTasks(false);
    setState(() {
      _tasks = tasks.map((task) => Task.fromMap(task)).toList();
    });
  }

  Future<void> _showTaskEditForm([Task? task]) async {
    List<Task>? subtasks;
    if (task?.id != null) {
      final subtaskMaps = await _databaseHelper.getSubtasks(task!.id!);
      subtasks = subtaskMaps.map((map) => Task.fromMap(map)).toList();
    }

    if (!mounted) return;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: AddTaskWidget(
            task: task,
            subtasks: subtasks,
            isEditMode: true,
          ),
        );
      },
      useRootNavigator: true,
    );

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      final updatedTask = result['task'] as Task;
      final newSubtasks = result['subtasks'] as List<Task>;

      if (task == null) {
        final parentId = await _databaseHelper.insertTask(updatedTask.toMap());
        for (var subtask in newSubtasks) {
          final subtaskMap = subtask.toMap();
          subtaskMap['parent_id'] = parentId;
          await _databaseHelper.insertTask(subtaskMap);
        }
      } else {
        await _databaseHelper.updateTask(updatedTask.toMap());
        // Insert new subtasks
        for (var subtask in newSubtasks) {
          final subtaskMap = subtask.toMap();
          subtaskMap['parent_id'] = task.id;
          await _databaseHelper.insertTask(subtaskMap);
        }
      }

      if (mounted) {
        await _loadTasks();
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    if (task.id != null) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await _databaseHelper.deleteTask(task.id!);
        _loadTasks();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshIndicatorKey.currentState?.show();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _loadTasks,
        child: _tasks.isEmpty
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
                  final task = _tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description != null) Text(task.description!),
                        if (task.dueDate != null)
                          Text(
                              'Due: ${task.dueDate!.toString().split(' ')[0]}'),
                        Text('Priority: ${task.priority}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showTaskEditForm(task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(task),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: AddTaskFloatingButtonWidget(
        onRefresh: _loadTasks,
      ),
    );
  }
}
