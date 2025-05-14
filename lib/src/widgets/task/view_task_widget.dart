import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/sub_task_list_widget.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'package:intl/intl.dart';

class ViewTaskWidget extends StatefulWidget {
  final Task task;
  final Function? onRefresh;
  final String title;

  const ViewTaskWidget({
    super.key,
    required this.task,
    this.onRefresh,
    this.title = 'View Task',
  });

  @override
  _ViewTaskWidgetState createState() => _ViewTaskWidgetState();
}

class _ViewTaskWidgetState extends State<ViewTaskWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Task _task;
  DateTime? _startDate;
  DateTime? _endDate;
  int _priority = 4; // Default priority
  final _dateFormat = DateFormat('yyyy-MM-dd');
  bool _isLoading = false; // Loading state

  Map<String, String> _errors = {};
  DateTime _minDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _maxDate = DateTime.now().add(Duration(days: 365 * 3));
  bool _showStartDate = false;
  bool _showEndDate = false;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _startDate = widget.task.startDate ?? DateTime.now();
    _endDate = widget.task.endDate ?? DateTime.now();
    _priority = widget.task.priority;

    _task = widget.task;
    _minDate = (_startDate ?? DateTime.now()).subtract(Duration(days: 7));
    _maxDate = (_endDate ?? DateTime.now()).add(Duration(days: 365 * 3));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_task.userId == AuthService().getLoggedInUser()!.id)
            IconButton(
              onPressed: () async {
                await _updateTask();

                if (mounted && _errors.isEmpty) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.save),
            ),
          if (_task.userId == AuthService().getLoggedInUser()!.id)
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildTaskContent(),
            if (_task.userId == AuthService().getLoggedInUser()!.id)
              const Divider(thickness: 5),
            SubTaskListWidget(
              task: _task,
              onRefresh: (Task task) {
                widget.onRefresh?.call(task);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [],
      ),
    );
  }

  Widget _buildTaskContent() {
    // Define a consistent row height
    const double rowHeight = 60.0;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Task completion status
            SizedBox(
              height: rowHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Task Completed',
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  _task.userId == AuthService().getLoggedInUser()!.id
                      ? Checkbox(
                          value: _task.isChecked,
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
                          activeColor:
                              TaskService().getPriorityColor(_priority),
                          onChanged: (bool? newValue) {
                            if (_task.userId ==
                                AuthService().getLoggedInUser()!.id) {
                              setState(() {
                                _task.isChecked = !_task.isChecked;
                              });
                              _updateTask();
                              widget.onRefresh?.call(_task);
                            }
                          },
                        )
                      : Text(_task.isChecked ? 'Completed' : 'Incomplete',
                          style: const TextStyle(
                            fontSize: 18,
                          )),
                ],
              ),
            ),
            // Task name
            SizedBox(
              height: rowHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Task Name',
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  _task.userId == AuthService().getLoggedInUser()!.id
                      ? Expanded(
                          child: TextField(
                            controller: _titleController,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              errorText: _errors['title'],
                            ),
                          ),
                        )
                      : Text(_task.title,
                          style: const TextStyle(
                            fontSize: 18,
                          )),
                ],
              ),
            ),

            // Description
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Description',
                    style: TextStyle(
                      fontSize: 18,
                    )),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                    hintText: 'enter description...',
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
              ],
            ),
            // Start date
            SizedBox(
              height: rowHeight,
              child: InkWell(
                onTap: () {
                  if (_task.userId == AuthService().getLoggedInUser()!.id) {
                    setState(() {
                      _showStartDate = !_showStartDate;
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Start Date',
                        style: TextStyle(
                          fontSize: 18,
                        )),
                    Row(
                      children: [
                        Text(
                          _startDate == null
                              ? 'No start date'
                              : _dateFormat.format(_startDate!),
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        if (_task.userId == AuthService().getLoggedInUser()!.id)
                          Icon(_showStartDate
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_task.userId == AuthService().getLoggedInUser()!.id)
              SizedBox(
                height: _showStartDate ? 216 : 0,
                child: CupertinoDatePicker(
                  initialDateTime: _startDate,
                  mode: CupertinoDatePickerMode.dateAndTime,
                  minimumDate: _minDate,
                  maximumDate: _maxDate,
                  onDateTimeChanged: (value) {
                    setState(() {
                      _startDate = value;
                    });
                  },
                ),
              ),
            if (_errors['start_date'] != null)
              Text(_errors['start_date']!,
                  style: const TextStyle(color: Colors.red)),

            // End date
            SizedBox(
              height: rowHeight,
              child: InkWell(
                onTap: () {
                  if (_task.userId == AuthService().getLoggedInUser()!.id) {
                    setState(() {
                      _showEndDate = !_showEndDate;
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('End Date',
                        style: TextStyle(
                          fontSize: 18,
                        )),
                    Row(
                      children: [
                        Text(
                          _endDate == null
                              ? 'No end date'
                              : _dateFormat.format(_endDate!),
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        if (_task.userId == AuthService().getLoggedInUser()!.id)
                          Icon(_showEndDate
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_task.userId == AuthService().getLoggedInUser()!.id)
              SizedBox(
                height: _showEndDate ? 216 : 0,
                child: CupertinoDatePicker(
                  initialDateTime: _endDate,
                  mode: CupertinoDatePickerMode.dateAndTime,
                  minimumDate: _minDate,
                  maximumDate: _maxDate,
                  onDateTimeChanged: (value) {
                    setState(() {
                      _endDate = value;
                    });
                  },
                ),
              ),
            if (_errors['end_date'] != null)
              Text(_errors['end_date']!,
                  style: const TextStyle(color: Colors.red)),
            // Priority
            SizedBox(
              height: rowHeight,
              child: Row(
                children: [
                  Icon(
                    Icons.flag,
                    color: TaskService().getPriorityColor(_priority),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_task.userId ==
                            AuthService().getLoggedInUser()!.id) {
                          TaskService().showPriorityPopUp(context, _priority,
                              (priority) {
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
                ],
              ),
            ),
          ],
        ));
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: !_isLoading, // Prevent dismissing during loading
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (widget.task.id != null) {
                          // Update both widget state and dialog state
                          setState(() {
                            _isLoading = true;
                          });
                          setDialogState(() {}); // Update dialog UI

                          try {
                            await TaskService().deleteTask(widget.task);

                            // Notify parent about deletion
                            widget.onRefresh?.call(null);

                            // Close both dialog and view task screen
                            if (mounted) {
                              Navigator.of(dialogContext).pop(); // Close dialog
                              Navigator.of(context)
                                  .pop(); // Close view task widget
                            }
                          } catch (e) {
                            // Handle error case
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error deleting task: $e')),
                              );

                              setState(() {
                                _isLoading = false;
                              });
                              setDialogState(() {}); // Update dialog UI
                            }
                          }
                        }
                      },
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey;
                      }
                      return Colors.red;
                    },
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Deleting...'),
                        ],
                      )
                    : const Text('Delete'),
              ),
            ],
          );
        });
      },
    );
  }
}
