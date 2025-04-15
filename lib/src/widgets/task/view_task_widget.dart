import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_sub_task_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/sub_tasks_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_date_picker_widget.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'package:intl/intl.dart';

class ViewTaskWidget extends StatefulWidget {
  final Task task;
  final bool isSubTask;
  final Function? onRefresh;

  const ViewTaskWidget({
    super.key,
    required this.task,
    this.isSubTask = false,
    this.onRefresh,
  });

  @override
  _ViewTaskWidgetState createState() => _ViewTaskWidgetState();
}

class _ViewTaskWidgetState extends State<ViewTaskWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Task _task;
  DateTime? _dueDate;
  int _priority = 4; // Default priority
  final _dateFormat = DateFormat('yyyy-MM-dd');
  bool _isLoading = false; // Loading state
  StreamSubscription<void>? _taskChangedSubscription;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;

    _task = widget.task;

    if (!widget.isSubTask) {
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
    super.dispose();
    if (!widget.isSubTask) {
      _taskChangedSubscription?.cancel();
    }
  }

  void _updateTask() async {
    setState(() {
      _isLoading = true; // Set loading to true
    });

    final updatedTask = Task(
      id: _task.id,
      parentId: _task.parentId,
      userId: _task.userId,
      projectId: _task.projectId,
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      priority: _priority,
      isChecked: _task.isChecked,
      createdAt: _task.createdAt,
      updatedAt: DateTime.now(),
      subTasks: _task.subTasks,
    );

    await TaskService().updateTask(updatedTask.toMap());
    setState(() {
      _isLoading = false;
    });
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return TaskDatePickerWidget(
          task: Task(
            id: _task.id,
            parentId: _task.parentId,
            userId: _task.userId,
            projectId: _task.projectId,
            title: _task.title,
            description: _task.description,
            dueDate: _dueDate,
            priority: _task.priority,
            isChecked: _task.isChecked,
            createdAt: _task.createdAt,
            updatedAt: _task.updatedAt,
            subTasks: _task.subTasks,
          ),
          onDateSelected: (date) {
            setState(() {
              _dueDate = date;
            });
            _updateTask();
          },
          onTimeSelected: (newTime) {
            setState(() {
              if (_dueDate != null && newTime != null) {
                _dueDate = DateTime(
                  _dueDate!.year,
                  _dueDate!.month,
                  _dueDate!.day,
                  newTime.hour,
                  newTime.minute,
                );
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with delete option
          _buildHeader(),

          // Main task content
          _buildTaskContent(),

          const Divider(thickness: 5),

          // Subtasks section
          SubTasksWidget(task: _task),

          AddSubTaskWidget(
            task: _task,
          ),
        ],
      ),
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
      children: [
        // Title with checkbox
        _buildTaskRow(
          icon: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: widget.task.isChecked,
              side: BorderSide(
                color: TaskService().getPriorityColor(widget.task.priority),
                width: 2.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(
                  color: TaskService().getPriorityColor(widget.task.priority),
                  width: 2.0,
                ),
              ),
              activeColor: TaskService().getPriorityColor(widget.task.priority),
              onChanged: (bool? newValue) {
                setState(() {
                  widget.task.isChecked = !widget.task.isChecked;
                  _updateTask();
                });
              },
            ),
          ),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          ),
        ),

        // Description
        if (widget.task.description != null && widget.task.description != '')
          _buildTaskRow(
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
        _buildTaskRow(
          icon: const Icon(Icons.calendar_month),
          content: InkWell(
            onTap: () => _showDatePicker(context),
            child: Text(
              _dueDate != null ? _dateFormat.format(_dueDate!) : 'Date',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),

        // Priority
        _buildTaskRow(
          icon: Icon(
            Icons.flag,
            color: TaskService().getPriorityColor(_priority),
          ),
          content: InkWell(
            onTap: () =>
                TaskService().showPriorityPopUp(context, _priority, (priority) {
              setState(() {
                _priority = priority;
              });
              _updateTask();
            }),
            child: Text(
              'Priority $_priority',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
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
                onTap: () => TaskService()
                    .showTaskEditForm(context, task, widget.isSubTask, (task) {
                  setState(() {
                    _task.subTasks[index] = task;
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

  Future<void> _loadSubTasksById() async {
    final tasks = await TaskService().getSubtasks(widget.task.id!);
    setState(() {
      _task.subTasks = tasks.map((task) => Task.fromMap(task)).toList();
    });
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
                  await TaskService().deleteTask(widget.task.id!);
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the view task widget
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
