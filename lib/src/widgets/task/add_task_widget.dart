import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/project.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/project_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/sub_task_list_widget.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../widgets/task/add_task_ai_widget.dart';

class AddTaskWidget extends StatefulWidget {
  final Task? task;
  final bool isParentTask;
  final Function? onRefresh;
  final String title;

  const AddTaskWidget({
    super.key,
    this.task,
    this.isParentTask = true,
    this.onRefresh,
    this.title = 'Add Task',
  });

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateInputController = TextEditingController();
  final _subtaskController = TextEditingController();
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now().add(Duration(hours: 3));
  int _priority = 4; // 4 is lowest priority, 1 is highest
  OverlayEntry? _overlayEntry;
  final FocusNode _dateInputFocusNode = FocusNode();
  final FocusNode _taskFocusNode = FocusNode();
  bool _isLoading = false;
  late Task _task;
  List<Project> _projects = [];
  int? _projectId;
  User? _user;
  bool _showStartDate = false;
  bool _showEndDate = false;

  @override
  void initState() {
    super.initState();
    _dateInputFocusNode.addListener(_onFocusChange);
    _taskFocusNode.requestFocus();
    _user = AuthService().getLoggedInUser();
    _task = widget.task ??
        Task(
          userId: _user?.id,
          title: "",
          parentId: widget.task?.id,
          projectId: widget.task?.projectId,
          priority: widget.task?.priority ?? 4,
          isChecked: widget.task?.isChecked ?? false,
          subTasks: [],
        );

    _loadProjects();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _dateInputController.dispose();
    _subtaskController.dispose();
    _dateInputFocusNode.removeListener(_onFocusChange);
    _dateInputFocusNode.dispose();
    _taskFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_dateInputFocusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _loadProjects() async {
    print('loading projects');
    final projects = await ProjectService().getAllProjects();
    print('after loading projects');
    print('projects: $projects');
    if (mounted) {
      setState(() {
        _projects = projects;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final task = _task.copyWith(
          parentId: widget.task?.id,
          userId: _user?.id ?? 0,
          projectId: _projectId,
          title: _taskController.text,
          description: _descriptionController.text,
          startDate: _startDate,
          endDate: _endDate,
          priority: _priority,
        );
        widget.onRefresh?.call(task);

        if (widget.isParentTask) {
          // Insert the main task and get its ID
          await TaskService().insertTask(task);
        }

        if (mounted) {
          Navigator.of(context).pop(true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task Created Successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating task: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
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
            onPressed: () => _showAIPopup(context),
            icon: const Image(
              image: AssetImage("assets/gemini_ai_icon.png"),
              height: 24,
            ),
          ),
          IconButton(
            onPressed: () => _submitForm(),
            icon: Icon(
              Icons.send,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 8,
                  right: 8,
                ),
                child: Column(
                  children: [
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.isParentTask)
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Project',
                                            style: TextStyle(
                                              fontSize: 18,
                                            )),
                                        DropdownButton(
                                            items: [
                                              DropdownMenuItem(
                                                value: null,
                                                child: Text('Inbox'),
                                              ),
                                              ...List.generate(
                                                _projects.length,
                                                (index) => DropdownMenuItem(
                                                  value: _projects[index].id,
                                                  child: Text(
                                                      _projects[index].name),
                                                ),
                                              ),
                                            ],
                                            value: _projectId ??
                                                widget.task?.projectId,
                                            onChanged: (value) {
                                              setState(() {
                                                _projectId = value;
                                              });
                                            }),
                                      ],
                                    ),
                                  ),
                                TextFormField(
                                  controller: _taskController,
                                  focusNode: _taskFocusNode,
                                  decoration: InputDecoration(
                                      hintText: 'Task Name',
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.all(16.0)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a task name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 4),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    hintText: 'Description',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16.0),
                                  ),
                                  maxLines: 6,
                                  minLines: 1,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _showStartDate = !_showStartDate;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Start Date',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                )),
                                            Row(
                                              children: [
                                                Text(_startDate == null
                                                    ? ''
                                                    : _dateFormat
                                                        .format(_startDate!)),
                                                Icon(_showStartDate
                                                    ? Icons.arrow_drop_up
                                                    : Icons.arrow_drop_down),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: _showStartDate ? 216 : 0,
                                        child: CupertinoDatePicker(
                                          key: ValueKey(_startDate.toString()),
                                          initialDateTime: _startDate,
                                          mode: CupertinoDatePickerMode
                                              .dateAndTime,
                                          minimumDate: DateTime.now()
                                              .subtract(Duration(days: 7)),
                                          maximumDate: DateTime.now()
                                              .add(Duration(days: 365 * 3)),
                                          onDateTimeChanged: (value) {
                                            setState(() {
                                              _startDate = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _showEndDate = !_showEndDate;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('End Date',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                )),
                                            Row(
                                              children: [
                                                Text(_endDate == null
                                                    ? ''
                                                    : _dateFormat
                                                        .format(_endDate!)),
                                                Icon(_showEndDate
                                                    ? Icons.arrow_drop_up
                                                    : Icons.arrow_drop_down),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: _showEndDate ? 216 : 0,
                                        child: CupertinoDatePicker(
                                          key: ValueKey(_endDate.toString()),
                                          initialDateTime: _endDate,
                                          mode: CupertinoDatePickerMode
                                              .dateAndTime,
                                          minimumDate: DateTime.now()
                                              .subtract(Duration(days: 7)),
                                          maximumDate: DateTime.now()
                                              .add(Duration(days: 365 * 3)),
                                          onDateTimeChanged: (value) {
                                            setState(() {
                                              _endDate = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // ElevatedButton(
                                    //   onPressed: () => {},
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: Colors.white,
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius: BorderRadius.circular(8),
                                    //     ),
                                    //   ),
                                    //   child: Row(
                                    //     mainAxisSize: MainAxisSize.min,
                                    //     children: [
                                    //       Icon(
                                    //         Icons.calendar_month,
                                    //         color: _startDate != null
                                    //             ? Colors.green
                                    //             : Colors.black,
                                    //       ),
                                    //       const SizedBox(width: 4),
                                    //       Text(
                                    //         _startDate == null
                                    //             ? 'Start Date'
                                    //             : '${_dateFormat.format(_startDate!)}',
                                    //         style: TextStyle(
                                    //           color: _startDate != null
                                    //               ? Colors.green
                                    //               : Colors.black,
                                    //         ),
                                    //       ),
                                    //       const SizedBox(width: 8),
                                    //       if (_startDate != null)
                                    //         SizedBox(
                                    //           width: 12,
                                    //           height: 24,
                                    //           child: IconButton(
                                    //             icon: const Icon(Icons.close,
                                    //                 color: Colors.red),
                                    //             padding: EdgeInsets.zero,
                                    //             onPressed: () {
                                    //               setState(() {
                                    //                 _startDate = null;
                                    //                 _dateInputController.clear();
                                    //               });
                                    //             },
                                    //           ),
                                    //         ),
                                    //     ],
                                    //   ),
                                    // ),
                                    // SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () => TaskService()
                                          .showPriorityPopUp(context, _priority,
                                              (priority) {
                                        setState(() {
                                          _priority = priority;
                                        });
                                      }),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.flag,
                                            color: TaskService()
                                                .getPriorityColor(_priority),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'P$_priority',
                                            style: TextStyle(
                                              color: TaskService()
                                                  .getPriorityColor(_priority),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                // Subtasks section
                                SubTaskListWidget(task: _task),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAIPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddTaskAIWidget(
          onAccept: (String taskName,
              String description,
              int priority,
              String startDate,
              String endDate,
              List<Map<String, dynamic>> subTasks) {
            setState(() {
              _taskController.text = taskName;
              _descriptionController.text = description;
              _startDate = DateTime.parse(startDate);
              _endDate = DateTime.parse(endDate);
              _priority = priority;

              // Clear existing subtasks
              _task.subTasks.clear();

              // Add new subtasks
              final subTasksList = recursiveTaskCreation(subTasks);
              print('subTasksList: $subTasksList');
              _task.subTasks.addAll(subTasksList);
            });

            // Show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI suggestions applied')),
            );
          },
        );
      },
    );
  }

  List<Task> recursiveTaskCreation(List<Map<String, dynamic>> subTasks) {
    final subTasksList = <Task>[];
    for (Map<String, dynamic> subTask in subTasks) {
      if (subTask['sub_tasks'] != null) {
        subTask['sub_tasks'] = recursiveTaskCreation(
            List<Map<String, dynamic>>.from(subTask['sub_tasks']));
      }
      subTasksList.add(Task(
        userId: _user?.id ?? 0,
        projectId: _projectId,
        title: subTask['task_name'],
        description: subTask['description'],
        priority: subTask['priority'] ?? _priority,
        startDate: subTask['start_date'] != null
            ? DateTime.parse(subTask['start_date'])
            : _startDate,
        endDate: subTask['end_date'] != null
            ? DateTime.parse(subTask['end_date'])
            : _endDate,
        isChecked: false,
        subTasks: subTask['sub_tasks'] ?? [],
      ));
    }
    return subTasksList;
  }
}
