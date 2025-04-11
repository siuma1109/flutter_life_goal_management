import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
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
  int _inboxTaskCount = 0;
  bool _isLoading = false;
  StreamSubscription? _inboxCountSubscription;
  StreamSubscription? _taskChangedSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen for inbox count updates
    _inboxCountSubscription = TaskBroadcast().inboxCountStream.listen((count) {
      setState(() {
        _inboxTaskCount = count;
      });
    });

    // Listen for task changes
    _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
      _loadInboxTaskCount();
    });

    _loadInboxTaskCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadInboxTaskCount();
  }

  @override
  void dispose() {
    _inboxCountSubscription?.cancel();
    _taskChangedSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadInboxTaskCount();
    }
  }

  Future<void> _loadInboxTaskCount() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await TaskService()
          .getInboxTasks(AuthService().getLoggedInUser()?.id ?? 0);
      if (mounted) {
        setState(() {
          _inboxTaskCount = tasks.length;
        });

        // Update the broadcast with the latest count
        TaskBroadcast().updateInboxCount(_inboxTaskCount);
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
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            ProfileInfoWidget(),
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.show_chart)),
                Tab(icon: Icon(Icons.menu)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const Center(child: Text("Dashboard")),
                  ProfileMenuWidget(
                    inboxTaskCount: _inboxTaskCount,
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
