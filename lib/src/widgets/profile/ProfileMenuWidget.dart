import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/project.dart';
import 'package:flutter_life_goal_management/src/screens/Profile/inbox_screen.dart';
import 'package:flutter_life_goal_management/src/screens/Project/project_screen.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/project_service.dart';
import 'package:flutter_life_goal_management/src/widgets/projects/AddProjectWidget.dart';

class ProfileMenuWidget extends StatefulWidget {
  final int inboxTaskCount;

  const ProfileMenuWidget({
    super.key,
    required this.inboxTaskCount,
  });

  @override
  State<ProfileMenuWidget> createState() => _ProfileMenuWidgetState();
}

class _ProfileMenuWidgetState extends State<ProfileMenuWidget> {
  List<Project> _projects = [];
  bool _isLoading = false;
  StreamSubscription? _projectChangedSubscription;

  @override
  void initState() {
    super.initState();
    _loadProjects();

    // Listen for project changes
    _projectChangedSubscription =
        TaskBroadcast().projectChangedStream.listen((_) {
      _loadProjects();
    });
  }

  @override
  void dispose() {
    _projectChangedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final projects = await ProjectService()
          .getAllProjectsByUserId(AuthService().getLoggedInUser()?.id ?? 0);
      print("projects: $projects");
      setState(() {
        _projects =
            projects.map((project) => Project.fromMap(project)).toList();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToInbox() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InboxScreen(
          inboxTaskCount: widget.inboxTaskCount,
        ),
      ),
    );
  }

  Future<void> _addProject() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useRootNavigator: true,
      builder: (context) => AddProjectWidget(),
    );

    if (result == true) {
      _loadProjects();
      // Notify other components about project changes
      TaskBroadcast().notifyProjectChanged();
    }
  }

  void _openProject(Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectScreen(
          project: project,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Inbox
          GestureDetector(
            onTap: _navigateToInbox,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.inbox,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text("Inbox", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    Text(widget.inboxTaskCount.toString(),
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text("Completed (TODO)", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const Text("2", style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Projects", style: TextStyle(fontSize: 16)),
                GestureDetector(
                  onTap: _addProject,
                  child: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _projects.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GestureDetector(
                onTap: () => _openProject(_projects[index]),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.tag,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(_projects[index].name,
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      Text(_projects[index].taskCount.toString(),
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
