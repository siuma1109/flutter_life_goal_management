import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/project.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/project_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/sub_task_list_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../widgets/task/add_task_ai_widget.dart';

class AddTaskWidget extends StatefulWidget {
  final Task? task;
  final bool isParentTask;
  final Function? onRefresh;

  const AddTaskWidget({
    super.key,
    this.task,
    this.isParentTask = true,
    this.onRefresh,
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
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
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
                    : SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _taskController,
                                focusNode: _taskFocusNode,
                                decoration: InputDecoration(
                                    hintText: 'Task Name',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16.0)),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Start Date',
                                            style: TextStyle(
                                              fontSize: 18,
                                            )),
                                        Text(_startDate == null
                                            ? ''
                                            : _dateFormat.format(_startDate!)),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 216,
                                      child: CupertinoDatePicker(
                                        initialDateTime: _startDate,
                                        mode:
                                            CupertinoDatePickerMode.dateAndTime,
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('End Date',
                                            style: TextStyle(
                                              fontSize: 18,
                                            )),
                                        Text(_endDate == null
                                            ? ''
                                            : _dateFormat.format(_endDate!)),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 216,
                                      child: CupertinoDatePicker(
                                        initialDateTime: _endDate,
                                        mode:
                                            CupertinoDatePickerMode.dateAndTime,
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
                                        borderRadius: BorderRadius.circular(8),
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
                              Divider(),
                              Padding(
                                padding: EdgeInsets.only(left: 18, right: 18),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (widget.isParentTask)
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
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _showAIPopup(context),
                                            style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 4),
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8))),
                                            child: const Image(
                                              image: AssetImage(
                                                  "assets/gemini_ai_icon.png"),
                                              height: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 50,
                                          child: ElevatedButton(
                                            onPressed: _submitForm,
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 4),
                                              backgroundColor: Colors.grey,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            child: Icon(
                                              Icons.send,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAIPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddTaskAIWidget(
          onAccept: (String taskName, String description,
              List<Map<String, dynamic>> subTasks) {
            setState(() {
              _taskController.text = taskName;
              _descriptionController.text = description;

              // Clear existing subtasks
              _task.subTasks.clear();

              // Add new subtasks
              final now = DateTime.now();
              for (Map<String, dynamic> subTask in subTasks) {
                final subtask = Task(
                  id: null,
                  parentId: null, // Will be set when the parent task is created
                  userId: _user?.id ?? 0,
                  projectId: _projectId,
                  title: subTask['task_name'],
                  description: subTask['description'],
                  priority: _priority,
                  startDate: _startDate,
                  endDate: _endDate,
                  createdAt: now,
                  updatedAt: now,
                  isChecked: false,
                  subTasks: [],
                );
                _task.subTasks.add(subtask);
              }
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
}
