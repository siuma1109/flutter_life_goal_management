import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/screens/search_screen.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_card_widget.dart';

class ExploreScreen extends StatefulWidget {
  final String title;

  const ExploreScreen({
    super.key,
    required this.title,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  TextEditingController searchController = TextEditingController();
  List<Task> _explorerTasks = <Task>[];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getExplorerTasks();

    // Add scroll listener for infinite scrolling
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMoreData) {
        _getExplorerTasks();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(),
              ),
            );
          },
          child: Container(
            height: 36,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.search, color: Colors.grey[600], size: 18),
                ),
                Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: _explorerTasks.isEmpty && !_isLoading
            ? Center(child: Text("No tasks found"))
            : Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(4),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1, // Square cells
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                      ),
                      itemCount: _explorerTasks.length,
                      itemBuilder: (context, index) {
                        return TaskCardWidget(task: _explorerTasks[index]);
                      },
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
      ),
      floatingActionButton: AddTaskFloatingButtonWidget(),
    );
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _page = 1;
      _explorerTasks.clear();
      _hasMoreData = true;
    });
    await _getExplorerTasks();
  }

  Future<void> _getExplorerTasks() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await TaskService().getExplorerTasks(_page);

      setState(() {
        if (tasks.isEmpty) {
          _hasMoreData = false;
        } else {
          _explorerTasks.addAll(tasks);
          _page++;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading explorer tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
}
