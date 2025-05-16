import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/screens/setting_screen.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/widgets/profile/dashboard_widget.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/profile/ProfileMenuWidget.dart';
import 'package:flutter_life_goal_management/src/widgets/profile_info_widget.dart';
import '../widgets/task/add_task_floating_button_widget.dart';

class ProfileScreen extends StatefulWidget {
  final User? user;
  final int? initialTabIndex;

  const ProfileScreen({super.key, this.initialTabIndex, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _tabBarKey = GlobalKey();
  final FocusNode _tab2FocusNode = FocusNode();
  int _taskCount = 0;
  int _finishedTaskCount = 0;
  int _pendingTaskCount = 0;
  int _inboxTaskCount = 0;
  StreamSubscription? _taskChangedSubscription;
  User? _user;
  bool _isLoading = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _user = widget.user ?? AuthService().getLoggedInUser();
    // Listen for task changes
    _taskChangedSubscription =
        TaskBroadcast().taskChangedStream.listen((Task? task) {
      _loadTaskCount();
    });

    _loadTaskCount();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
    _tabBarKey.currentState?.dispose();
    _tab2FocusNode.dispose();
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
      _isLoading = true;
    });

    try {
      final getTasksCountResult = await TaskService().getTasksCount(
        userId: _user?.id,
      );
      final inboxTaskCount = await TaskService().getInboxTasksCount(
        userId: _user?.id,
      );
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
          _isLoading = false;
          _isInitialLoading = false;
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
        initialIndex: widget.initialTabIndex ?? 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            ProfileInfoWidget(
              isInitialLoading: _isInitialLoading,
              isLoading: _isLoading,
              taskCount: _taskCount,
              tabController: _tabController,
              user: _user!,
            ),
            TabBar(
              controller: _tabController,
              key: _tabBarKey,
              tabs: [
                Tab(icon: Icon(Icons.show_chart)),
                Tab(
                  child:
                      Focus(focusNode: _tab2FocusNode, child: Icon(Icons.menu)),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  DashboardWidget(
                    isInitialLoading: _isInitialLoading,
                    isLoading: _isLoading,
                    finishedTaskCount: _finishedTaskCount,
                    pendingTaskCount: _pendingTaskCount,
                  ),
                  ProfileMenuWidget(
                    isInitialLoading: _isInitialLoading,
                    isLoading: _isLoading,
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
