import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_list_widget.dart';

class ExploreTaskListWidget extends StatefulWidget {
  final String? search;
  const ExploreTaskListWidget({super.key, this.search});

  @override
  State<ExploreTaskListWidget> createState() => _ExploreTaskListWidgetState();
}

class _ExploreTaskListWidgetState extends State<ExploreTaskListWidget> {
  List<Task> _tasks = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _search = widget.search ?? '';
    _loadTasks();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMoreData) {
        _loadTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child: _tasks.isEmpty
          ? const Center(child: Text('No tasks found'))
          : TaskListWidget(
              tasks: _tasks,
              scrollController: _scrollController,
            ),
    );
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _page = 1;
      _tasks.clear();
      _hasMoreData = true;
    });
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_hasMoreData) {
        final tasks = await TaskService().getExplorerTasks(
          _page,
          _search,
        );
        setState(() {
          if (tasks.isEmpty) {
            _hasMoreData = false;
          } else {
            _tasks.addAll(tasks);
            _page++;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
