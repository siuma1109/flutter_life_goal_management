import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_date_picker_widget.dart';
import '../../models/task.dart';
import '../../services/database_helper.dart';
import '../../services/task_service.dart';
import 'package:intl/intl.dart';

class ViewTaskWidget extends StatefulWidget {
  final Task task;
  final VoidCallback? onRefresh;

  const ViewTaskWidget(
      {super.key, required this.task, required this.onRefresh});

  @override
  _ViewTaskWidgetState createState() => _ViewTaskWidgetState();
}

class _ViewTaskWidgetState extends State<ViewTaskWidget> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<Task> _subTasks = [];
  DateTime? _dueDate;
  int _priority = 4; // Default priority
  final _dateFormat = DateFormat('yyyy-MM-dd');
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _loadSubTasksById();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateTask() async {
    setState(() {
      _isLoading = true; // Set loading to true
    });

    final updatedTask = Task(
      id: widget.task.id,
      parentId: widget.task.parentId,
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      priority: _priority,
      isChecked: widget.task.isChecked,
      createdAt: widget.task.createdAt,
      updatedAt: DateTime.now(),
    );

    await _databaseHelper.updateTask(updatedTask.toMap());
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
            widget.onRefresh?.call();
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
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
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
            ),
            // Title row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 50,
                    child: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: widget.task.isChecked,
                        side: BorderSide(
                          color: TaskService()
                              .getPriorityColor(widget.task.priority),
                          width: 2.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(
                            color: TaskService()
                                .getPriorityColor(widget.task.priority),
                            width: 2.0,
                          ),
                        ),
                        activeColor: TaskService()
                            .getPriorityColor(widget.task.priority),
                        onChanged: (bool? newValue) {
                          setState(() {
                            widget.task.isChecked = !widget.task.isChecked;
                            _updateTask();
                            widget.onRefresh?.call();
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Description row
            if (widget.task.description != null &&
                widget.task.description != '')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 50,
                      child: Icon(Icons.description),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        minLines: 1,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),

            // Date row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 50,
                    child: Icon(Icons.calendar_month),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showDatePicker(context),
                      child: Text(
                        _dueDate != null
                            ? _dateFormat.format(_dueDate!)
                            : 'Date',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Priority row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 50,
                    child: Icon(
                      Icons.flag,
                      color: TaskService().getPriorityColor(_priority),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showPriorityDialog(context),
                      child: Text(
                        'Priority $_priority',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              thickness: 5,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 50,
                    child: Icon(Icons.list),
                  ),
                  Expanded(
                    child: Text(
                      "Sub Tasks",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _subTasks.isEmpty
                  ? Container(
                      height: 200,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          Center(
                            child: Text('No tasks found'),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: _subTasks.length,
                        itemBuilder: (context, index) {
                          final task = _subTasks[index];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      Colors.black12, // Change color as needed
                                  width: 1.0, // Adjust width as needed
                                ),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () => _showTaskEditForm(task),
                              child: ListTile(
                                leading: Transform.scale(
                                  scale:
                                      1.2, // Adjust the scale factor as needed
                                  child: Checkbox(
                                    value: task.isChecked,
                                    side: BorderSide(
                                      color: TaskService()
                                          .getPriorityColor(task.priority),
                                      width: 2.0, // Adjust the width as needed
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      side: BorderSide(
                                        color: TaskService()
                                            .getPriorityColor(task.priority),
                                        width: 2.0,
                                      ),
                                    ),
                                    activeColor: TaskService()
                                        .getPriorityColor(task.priority),
                                    onChanged: (bool? newValue) {
                                      task.isChecked = !task.isChecked;
                                      setState(() {
                                        _subTasks[index] = task;
                                        _databaseHelper
                                            .updateTask(task.toMap());
                                      });
                                    },
                                  ),
                                ),
                                title: Text(task.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task.description != null &&
                                        task.description != '')
                                      Text(task.description!),
                                    if (task.dueDate != null)
                                      Text(
                                          'Due: ${task.dueDate!.toString().split(' ')[0]}'),
                                    Text('Priority: ${task.priority}'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            InkWell(
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
                  )),
              onTap: () async {
                final result = await showModalBottomSheet(
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
                            task: widget.task, onRefresh: _loadSubTasksById),
                      );
                    });

                if (result == true) {
                  widget.onRefresh?.call();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> _loadSubTasksById() async {
    final tasks = await _databaseHelper.getSubtasks(widget.task.id!);
    setState(() {
      _subTasks = tasks.map((task) => Task.fromMap(task)).toList();
    });
  }

  void _showTaskEditForm(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ViewTaskWidget(
            task: task,
            onRefresh: _loadSubTasksById,
          ),
        );
      },
    );
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
                    widget.onRefresh?.call();
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (widget.task.id != null) {
                  await _databaseHelper.deleteTask(widget.task.id!);
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the view task widget
                  widget.onRefresh?.call();
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
