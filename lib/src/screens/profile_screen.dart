import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/widgets/profile_info_widget.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../widgets/task/add_task_floating_button_widget.dart';
import '../widgets/task/task_list_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
    final tasks = await _databaseHelper.getAllTasks(
        false, AuthService().getLoggedInUser()?.id);
    setState(() {
      _tasks = tasks.map((task) => Task.fromMap(task)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AuthService().getLoggedInUser()?.username ?? 'Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            ProfileInfoWidget(),
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.show_chart)),
                Tab(icon: Icon(Icons.task)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Text("Dashboard"),
                  RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _loadTasks,
                    child: TaskListWidget(
                      tasks: _tasks,
                      onRefresh: _loadTasks,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AddTaskFloatingButtonWidget(
        onRefresh: _loadTasks,
      ),
    );
  }
}
