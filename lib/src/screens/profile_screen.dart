import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';
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
  final TaskService _taskService = TaskService();
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
                  return Container(
                    decoration: BoxDecoration(
                      border: index < _tasks.length - 1
                          ? Border(
                              bottom: BorderSide(
                                color: Colors.black12, // Change color as needed
                                width: 1.0, // Adjust width as needed
                              ),
                            )
                          : null,
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        _taskService.showTaskEditForm(
                            context, task, _loadTasks);
                      },
                      child: ListTile(
                        leading: Transform.scale(
                          scale: 1.2, // Adjust the scale factor as needed
                          child: Checkbox(
                            value: task.isChecked,
                            side: BorderSide(
                              color:
                                  TaskService().getPriorityColor(task.priority),
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
                            activeColor:
                                TaskService().getPriorityColor(task.priority),
                            onChanged: (bool? newValue) {
                              task.isChecked = !task.isChecked;
                              setState(() {
                                _tasks[index] = task;
                                _databaseHelper.updateTask(task.toMap());
                              });
                            },
                          ),
                        ),
                        title: Text(task.title),
                        subtitle: (task.description != null &&
                                task.description != '')
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.description!),
                                  if (task.dueDate != null)
                                    Text(
                                        task.dueDate!.toString().split(' ')[0]),
                                ],
                              )
                            : null,
                      ),
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
