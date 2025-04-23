import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/screens/setting_screen.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/widgets/profile/dashboard_widget.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/profile/ProfileMenuWidget.dart';
import 'package:flutter_life_goal_management/src/widgets/profile_info_widget.dart';
import '../widgets/task/add_task_floating_button_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  int _taskCount = 0;
  int _finishedTaskCount = 0;
  int _pendingTaskCount = 0;
  int _inboxTaskCount = 0;
  StreamSubscription? _taskChangedSubscription;
  User? _user;
  bool _isLoadingTaskCount = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _user = AuthService().getLoggedInUser();
    // Listen for task changes
    _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
      _loadTaskCount();
    });

    _loadTaskCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTaskCount();
  }

  @override
  void dispose() {
    _taskChangedSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTaskCount();
    }
  }

  Future<void> _loadTaskCount() async {
    setState(() {
      _isLoadingTaskCount = true;
    });

    try {
      final getTasksCountResult = await TaskService().getTasksCount();
      final inboxTaskCount = await TaskService().getInboxTasksCount();
      if (mounted) {
        setState(() {
          _taskCount = getTasksCountResult['tasks_count'] ?? 0;
          _inboxTaskCount = inboxTaskCount;
          _finishedTaskCount = getTasksCountResult['finished_tasks_count'] ?? 0;
          _pendingTaskCount = getTasksCountResult['pending_tasks_count'] ?? 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTaskCount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user?.name ?? 'Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            ProfileInfoWidget(
              isLoadingTaskCount: _isLoadingTaskCount,
              taskCount: _taskCount,
            ),
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.show_chart)),
                Tab(icon: Icon(Icons.menu)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  DashboardWidget(
                    isLoadingTaskCount: _isLoadingTaskCount,
                    finishedTaskCount: _finishedTaskCount,
                    pendingTaskCount: _pendingTaskCount,
                  ),
                  ProfileMenuWidget(
                    inboxTaskCount: _inboxTaskCount,
                    finishedTaskCount: _finishedTaskCount,
                    user: _user!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const AddTaskFloatingButtonWidget(),
    );
  }
}
