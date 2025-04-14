import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/project.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/project_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_priority_selector_widget.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../widgets/task/task_date_picker_widget.dart';

class AddTaskWidget extends StatefulWidget {
  final Task? task;
  final List<Task>? subtasks;
  final bool isAddSubTask;

  const AddTaskWidget({
    super.key,
    this.task,
    this.subtasks,
    this.isAddSubTask = false,
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
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _timeFormat = DateFormat('hh:mm a');
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  DateTime? _suggestedDate;
  int _priority = 4; // 4 is lowest priority, 1 is highest
  OverlayEntry? _overlayEntry;
  final FocusNode _dateInputFocusNode = FocusNode();
  final FocusNode _taskFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  bool _isLoading = false;
  List<Task> _subtasks = [];
  List<Project> _projects = [];
  int? _projectId;

  @override
  void initState() {
    super.initState();
    _dateInputFocusNode.addListener(_onFocusChange);
    _taskFocusNode.requestFocus();
    dotenv.load();
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
    final projects = await ProjectService()
        .getAllProjectsByUserId(AuthService().getLoggedInUser()?.id ?? 0);
    setState(() {
      _projects = projects.map((project) => Project.fromMap(project)).toList();
    });
  }

  void _showDatePicker(BuildContext context) {
    _dateInputFocusNode.requestFocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return TaskDatePickerWidget(
          task: widget.task ??
              Task(
                id: null,
                parentId: null,
                userId: AuthService().getLoggedInUser()?.id ?? 0,
                projectId: widget.task?.projectId ?? null,
                title: "",
                priority: _priority,
                dueDate: _dueDate,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
          onDateSelected: (date) {
            setState(() {
              _dueDate = date;
              if (date != null) {
                _dateInputController.text = _dateFormat.format(date);
              } else {
                _dateInputController.clear();
              }
            });
          },
          onTimeSelected: (newTime) {
            setState(() {
              _dueTime = newTime;
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

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  void _notifyChanges() {
    // Broadcast the change
    TaskBroadcast().notifyTasksChanged();

    // If it's a task with a project, also notify project changes
    if (_projectId != null) {
      TaskBroadcast().notifyProjectChanged(_projectId);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final now = DateTime.now();
        final task = Task(
          parentId: widget.task?.id,
          userId: AuthService().getLoggedInUser()?.id ?? 0,
          projectId: _projectId,
          title: _taskController.text,
          description: _descriptionController.text,
          dueDate: _dueDate,
          priority: _priority,
          createdAt: widget.task?.createdAt ?? now,
          updatedAt: now,
        );

        await TaskService().insertTask(task.toMap());

        if (mounted) {
          _notifyChanges();
          Navigator.of(context).pop(true);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task Created Successfully')),
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showDatePicker(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: _dueDate != null
                                    ? Colors.green
                                    : Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _dueDate == null
                                    ? 'Date'
                                    : '${_dateFormat.format(_dueDate!)}',
                                style: TextStyle(
                                  color: _dueDate != null
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_dueDate != null)
                                SizedBox(
                                  width: 12,
                                  height: 24,
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      setState(() {
                                        _dueDate = null;
                                        _dateInputController.clear();
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => TaskService().showPriorityPopUp(
                              context, _priority, (priority) {
                            setState(() {
                              _priority = priority;
                            });
                          }),
                          child: Row(
                            children: [
                              Icon(
                                Icons.flag,
                                color:
                                    TaskService().getPriorityColor(_priority),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'P$_priority',
                                style: TextStyle(
                                  color:
                                      TaskService().getPriorityColor(_priority),
                                ),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.only(left: 18, right: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
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
                                        child: Text(_projects[index].name),
                                      ),
                                    ),
                                  ],
                                  value: _projectId ?? widget.task?.projectId,
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
                                  onPressed: () => _showAIPopup(context),
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 4),
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  child: const Image(
                                    image:
                                        AssetImage("assets/gemini_ai_icon.png"),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 4),
                                    backgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
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
    );
  }

  void _showAIPopup(BuildContext context) {
    final TextEditingController aiInputController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AI Task Suggestion'),
          content: TextField(
            controller: aiInputController,
            decoration: const InputDecoration(hintText: 'Enter your goal...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchAIDetails(aiInputController.text);
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchAIDetails(String goal) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final API_KEY = dotenv.env['DIFY_API_KEY'];

      final response = await http.post(
        Uri.parse('https://api.dify.ai/v1/chat-messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY'
        },
        body: json.encode({
          'query': goal,
          'user': 1,
          'inputs': {'goal': goal}
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final answer = data['answer'];

        final cleanedAnswer =
            answer.replaceAll(RegExp(r'```json|```'), '').trim();

        final answerData = json.decode(cleanedAnswer);

        setState(() {
          _taskController.text = answerData['task_name'] ?? '';
          _descriptionController.text = answerData['description'] ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI suggestions fetched successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch AI suggestions')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
