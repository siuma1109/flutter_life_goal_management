import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/broadcasts/user_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/screens/setting_screen.dart';
import 'package:flutter_life_goal_management/src/widgets/profile/dashboard_widget.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/profile/ProfileMenuWidget.dart';
import 'package:flutter_life_goal_management/src/widgets/profile_info_widget.dart';
import 'package:go_router/go_router.dart';
import '../widgets/task/add_task_floating_button_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  int _taskCount = 0;
  int _inboxTaskCount = 0;
  bool _isLoading = false;
  StreamSubscription? _taskChangedSubscription;
  User? _user;
  StreamSubscription? _userChangedSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Listen for task changes
    _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
      _loadTaskCount();
    });

    // Listen for user changes
    _userChangedSubscription = UserBroadcast().userChangedStream.listen((_) {
      _loadUser();
    });
    _loadUser();
    _loadTaskCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTaskCount();
    _loadUser();
  }

  @override
  void dispose() {
    _taskChangedSubscription?.cancel();
    _userChangedSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTaskCount();
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
    });

    final user = await AuthService().getLoggedInUser();

    if (user == null && mounted) {
      context.go('/login');
    }

    setState(() {
      _isLoading = false;
      _user = user;
    });
  }

  Future<void> _loadTaskCount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final taskCount = await TaskService().getTasksCount();
      final inboxTaskCount = await TaskService().getInboxTasksCount();
      if (mounted) {
        setState(() {
          _taskCount = taskCount;
          _inboxTaskCount = inboxTaskCount;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while user data is being loaded
    if (_isLoading || _user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
            ProfileInfoWidget(taskCount: _taskCount, user: _user!),
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.show_chart)),
                Tab(icon: Icon(Icons.menu)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  DashboardWidget(),
                  ProfileMenuWidget(
                    inboxTaskCount: _inboxTaskCount,
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
