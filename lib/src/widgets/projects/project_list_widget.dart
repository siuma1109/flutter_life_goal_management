import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/project.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/screens/Project/project_screen.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/project_service.dart';
import 'package:flutter_life_goal_management/src/widgets/projects/AddProjectWidget.dart';

class ProjectListWidget extends StatefulWidget {
  final String? search;
  final User? user;
  const ProjectListWidget({
    super.key,
    this.search,
    this.user,
  });

  @override
  _ProjectListWidgetState createState() => _ProjectListWidgetState();
}

class _ProjectListWidgetState extends State<ProjectListWidget> {
  List<Project> _projects = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  String _search = '';
  StreamSubscription? _projectChangedSubscription;

  @override
  void initState() {
    super.initState();
    _search = widget.search ?? '';
    _loadProjects();
    // Listen for project changes
    _projectChangedSubscription =
        TaskBroadcast().projectChangedStream.listen((_) {
      _refreshProjects();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.5 &&
          !_isLoading &&
          _hasMoreData) {
        _loadProjects();
      }
    });
  }

  @override
  void dispose() {
    _projectChangedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _search.isNotEmpty && _projects.isEmpty
        ? const Center(child: Text('No projects found'))
        : RefreshIndicator(
            onRefresh: _refreshProjects,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.search == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Projects", style: TextStyle(fontSize: 16)),
                        if (widget.user?.id ==
                            AuthService().getLoggedInUser()?.id)
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
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _projects.length,
                    controller: _scrollController,
                    itemBuilder: (context, index) => Padding(
                      key: Key(_projects[index].id.toString()),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: GestureDetector(
                        onTap: () => _openProject(_projects[index]),
                        child: Container(
                          padding: const EdgeInsets.only(top: 10),
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
                              Text(_projects[index].tasksCount.toString(),
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Future<void> _refreshProjects() async {
    _projects = [];
    _page = 1;
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final projects = await ProjectService().getAllProjectsWithPagination(
        search: widget.search,
        page: _page,
        userId: widget.user?.id,
      );
      print("projects: $projects");
      setState(() {
        _projects.addAll(projects);
        _page++;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addProject() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useRootNavigator: true,
      builder: (context) => AddProjectWidget(user: widget.user),
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
          user: widget.user == null
              ? AuthService().getLoggedInUser()!
              : widget.user!,
        ),
      ),
    );
  }
}
