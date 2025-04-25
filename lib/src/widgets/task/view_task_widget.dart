import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/comment_list_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/sub_task_list_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_row_widget.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'package:intl/intl.dart';

class ViewTaskWidget extends StatefulWidget {
  final Task task;
  final Function? onRefresh;

  const ViewTaskWidget({
    super.key,
    required this.task,
    this.onRefresh,
  });

  @override
  _ViewTaskWidgetState createState() => _ViewTaskWidgetState();
}

class _ViewTaskWidgetState extends State<ViewTaskWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _commentController;
  late Task _task;
  DateTime? _startDate;
  DateTime? _endDate;
  int _priority = 4; // Default priority
  final _dateFormat = DateFormat('yyyy-MM-dd');
  bool _isLoading = false; // Loading state
  StreamSubscription<void>? _taskChangedSubscription;
  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _commentController = TextEditingController();
    _startDate = widget.task.startDate ?? DateTime.now();
    _endDate = widget.task.endDate ?? DateTime.now();
    _priority = widget.task.priority;

    _task = widget.task;
    if (_task.id != null) {
      _loadSubTasksById();
      // Listen for task changes
      _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
        _loadSubTasksById();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    super.dispose();
    _taskChangedSubscription?.cancel();
  }

  Future<void> _updateTask() async {
    if (mounted) {
      setState(() {
        _errors = {};
        _isLoading = true; // Set loading to true
      });
    }

    final updatedTask = Task(
      id: widget.task.id,
      parentId: widget.task.parentId,
      userId: widget.task.userId,
      projectId: widget.task.projectId,
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
      endDate: _endDate,
      priority: _priority,
      isChecked: widget.task.isChecked,
      subTasks: widget.task.subTasks,
    );

    final result = await TaskService().updateTask(updatedTask);

    if (result != null && result['errors'] != null) {
      setState(() {
        print('error: ${result['errors']}');
        _errors = result['errors']
            .map((key, value) => MapEntry(key, value.join('\n')))
            .cast<String, String>();
      });
    }

    if (_errors.isEmpty) {
      widget.onRefresh?.call(Task.fromJson(result));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildTaskContent(),
              if (_task.userId == AuthService().getLoggedInUser()!.id)
                const Divider(thickness: 5),
              SubTaskListWidget(
                task: _task,
              ),
              const Divider(thickness: 5),
              CommentListWidget(task: _task),
              Padding(
                padding: const EdgeInsets.all(16),
              ),
            ],
          );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
                    Text('Delete Task'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title with checkbox
        TaskRowWidget(
          icon: widget.task.userId == AuthService().getLoggedInUser()!.id
              ? Checkbox(
                  value: widget.task.isChecked,
                  side: BorderSide(
                    color: TaskService().getPriorityColor(_priority),
                    width: 2.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(
                      color: TaskService().getPriorityColor(_priority),
                      width: 2.0,
                    ),
                  ),
                  activeColor: TaskService().getPriorityColor(_priority),
                  onChanged: (bool? newValue) {
                    setState(() {
                      widget.task.isChecked = !widget.task.isChecked;
                    });
                    _updateTask();
                  },
                )
              : const SizedBox.shrink(),
          content: TextField(
            controller: _titleController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
              errorText: _errors['title'] ?? null,
            ),
          ),
        ),

        // Description
        if (widget.task.description != null && widget.task.description != '')
          TaskRowWidget(
            icon: const Icon(Icons.description),
            content: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ),

        // Due date
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Start Date',
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  Text(_startDate == null
                      ? 'No start date'
                      : _dateFormat.format(_startDate!)),
                ],
              ),
              if (_task.userId == AuthService().getLoggedInUser()!.id)
                SizedBox(
                  height: 216,
                  child: CupertinoDatePicker(
                    initialDateTime: _startDate,
                    mode: CupertinoDatePickerMode.dateAndTime,
                    minimumDate: DateTime.now().subtract(Duration(days: 7)),
                    maximumDate: DateTime.now().add(Duration(days: 365 * 3)),
                    onDateTimeChanged: (value) {
                      setState(() {
                        _startDate = value;
                      });
                    },
                  ),
                ),
              if (_errors['start_date'] != null)
                Text(_errors['start_date']!,
                    style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('End Date',
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  Text(_endDate == null
                      ? 'No end date'
                      : _dateFormat.format(_endDate!)),
                ],
              ),
              if (_task.userId == AuthService().getLoggedInUser()!.id)
                SizedBox(
                  height: 216,
                  child: CupertinoDatePicker(
                    initialDateTime: _endDate,
                    mode: CupertinoDatePickerMode.dateAndTime,
                    minimumDate: DateTime.now().subtract(Duration(days: 7)),
                    maximumDate: DateTime.now().add(Duration(days: 365 * 3)),
                    onDateTimeChanged: (value) {
                      setState(() {
                        _endDate = value;
                      });
                    },
                  ),
                ),
              if (_errors['end_date'] != null)
                Text(_errors['end_date']!, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        // Priority
        TaskRowWidget(
          icon: Icon(
            Icons.flag,
            color: TaskService().getPriorityColor(_priority),
          ),
          content: InkWell(
            onTap: () {
              if (_task.userId == AuthService().getLoggedInUser()!.id) {
                TaskService().showPriorityPopUp(context, _priority, (priority) {
                  setState(() {
                    _priority = priority;
                  });
                  _updateTask();
                });
              }
            },
            child: Text(
              'Priority $_priority',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        if (_task.userId == AuthService().getLoggedInUser()!.id)
          TaskRowWidget(
            onTap: () async {
              await _updateTask();
              if (mounted && _errors.isEmpty) {
                Navigator.of(context).pop();
              }
            },
            icon: Icon(Icons.save),
            content: Text('Save Task'),
          ),
      ],
    );
  }

  Future<void> _loadSubTasksById() async {
    final subTasks = await TaskService().getSubtasks(widget.task.id!);
    if (mounted) {
      setState(() {
        _task.subTasks = subTasks;
      });
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (widget.task.id != null) {
                  print("Deleting task: ${widget.task.id}");
                  print("Deleting task projectId: ${widget.task.projectId}");
                  await TaskService().deleteTask(widget.task);
                }
                widget.onRefresh?.call(null);
                Navigator.of(dialogContext).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the view task widget
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentInputBar() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 8,
        right: 8,
        top: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitComment,
            ),
          ],
        ),
      ),
    );
  }

  void _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    if (_task.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot add comment to unsaved task')),
      );
      return;
    }

    try {
      // Submit comment using TaskService
      await TaskService().addComment(_task.id!, _commentController.text);

      // Clear the input field
      _commentController.clear();

      // No need to manually notify as the addComment method already broadcasts changes
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: ${e.toString()}')),
      );
    }
  }
}
