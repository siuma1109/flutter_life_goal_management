import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_date_picker_widget.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'package:intl/intl.dart';

class ViewTaskWidget extends StatefulWidget {
  final Task task;

  const ViewTaskWidget({
    super.key,
    required this.task,
  });

  @override
  _ViewTaskWidgetState createState() => _ViewTaskWidgetState();
}

class _ViewTaskWidgetState extends State<ViewTaskWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<Task> _subTasks = [];
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
    _loadSubTasksById();
    // Listen for task changes
    _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
      _loadSubTasksById();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
    _taskChangedSubscription?.cancel();
  }

  void _updateTask() async {
    setState(() {
      _isLoading = true; // Set loading to true
    });

    final updatedTask = Task(
      id: widget.task.id,
      parentId: widget.task.parentId,
      userId: widget.task.userId,
      projectId: widget.task.projectId,
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      priority: _priority,
      isChecked: widget.task.isChecked,
      createdAt: widget.task.createdAt,
      updatedAt: DateTime.now(),
    );

    await TaskService().updateTask(updatedTask.toMap());
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
            id: widget.task.id,
            parentId: widget.task.parentId,
            userId: widget.task.userId,
            projectId: widget.task.projectId,
            title: widget.task.title,
            description: widget.task.description,
            dueDate: _dueDate,
            priority: widget.task.priority,
            isChecked: widget.task.isChecked,
            createdAt: widget.task.createdAt,
            updatedAt: widget.task.updatedAt,
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
          if (_subTasks.isNotEmpty) _buildSubtasksSection(),

          // Add subtask button
          _buildAddSubtaskButton(),
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
            onTap: () => _showPriorityDialog(context),
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
    final completeSubTasks = _subTasks.where((task) => task.isChecked).length;
    return Column(
      children: [
        _buildTaskRow(
          icon: const Icon(Icons.list),
          content: Text(
            "Sub Tasks ($completeSubTasks/${_subTasks.length})",
            style: const TextStyle(fontSize: 16),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _subTasks.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final task = _subTasks[index];
            return Container(
              decoration: BoxDecoration(
                border: index < _subTasks.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: Colors.black12,
                          width: 1.0,
                        ),
                      )
                    : null,
              ),
              child: GestureDetector(
                onTap: () => TaskService().showTaskEditForm(context, task),
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
                          _subTasks[index] = task;
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

  Widget _buildAddSubtaskButton() {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: AddTaskWidget(
                task: widget.task,
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 50,
              child: Icon(
                Icons.add,
                color: Colors.redAccent,
              ),
            ),
            Expanded(
              child: Text(
                "Add sub task",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSubTasksById() async {
    final tasks = await TaskService().getSubtasks(widget.task.id!);
    setState(() {
      _subTasks = tasks.map((task) => Task.fromMap(task)).toList();
    });
  }

  void _showPriorityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Priority'),
          content: SingleChildScrollView(
            child: ListBody(
              children: List.generate(4, (index) {
                final priority = index + 1;
                return ListTile(
                  title: Text('P$priority'),
                  onTap: () {
                    setState(() {
                      _priority = priority;
                    });
                    _updateTask();
                    Navigator.of(context).pop();
                  },
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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
