import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_card.dart';

class TodayTasksWidget extends StatefulWidget {
  final List<Task> tasks;
  final Function loadTasks;
  final bool isLoading;
  final ScrollController? scrollController;

  const TodayTasksWidget({
    super.key,
    required this.tasks,
    required this.loadTasks,
    required this.isLoading,
    this.scrollController,
  });

  @override
  State<TodayTasksWidget> createState() => _TodayTasksWidgetState();
}

class _TodayTasksWidgetState extends State<TodayTasksWidget> {
  late List<Task> _tasks;
  bool _showAllTasks = false;
  final GlobalKey _firstItemKey = GlobalKey();
  double _itemHeight = 0;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateItemHeight();
    });
  }

  @override
  void didUpdateWidget(TodayTasksWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tasks != oldWidget.tasks) {
      setState(() {
        _tasks = widget.tasks;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateItemHeight();
      });
    }
  }

  void _calculateItemHeight() {
    if (_firstItemKey.currentContext != null && _tasks.isNotEmpty) {
      final RenderBox renderBox =
          _firstItemKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _itemHeight = renderBox.size.height;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int maxDisplayCount = _showAllTasks ? 4 : 2;

    double listViewHeight;
    if (_itemHeight > 0) {
      final double verticalPadding = 16.0;
      final double itemMargin = 8.0;

      int actualItemCount = _tasks.isEmpty
          ? 0
          : (_tasks.length > maxDisplayCount ? maxDisplayCount : _tasks.length);

      double fullItemHeight = _itemHeight + (itemMargin * 2);

      listViewHeight = (fullItemHeight * actualItemCount) + verticalPadding;

      if (_tasks.isEmpty) {
        listViewHeight = 80.0;
      }
    } else {
      listViewHeight = _showAllTasks ? 350 : 180;
    }

    return _tasks.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Today Tasks',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: listViewHeight,
                child: _tasks.isEmpty
                    ? const Center(child: Text('No tasks'))
                    : ListView.builder(
                        controller: widget.scrollController,
                        itemCount: _tasks.length,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          if (index < _tasks.length) {
                            return TaskCard(
                              key: Key(_tasks[index].id.toString()),
                              task: _tasks[index],
                              onEdited: (Task? task) {
                                if (task != null) {
                                  setState(() {
                                    _tasks[index] = task;
                                  });
                                }
                              },
                            );
                          }
                          return null;
                        },
                      ),
              ),
              if (!_showAllTasks && _tasks.length > 2)
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _showAllTasks = true;
                      if (!widget.isLoading) {
                        widget.loadTasks();
                      }
                    }),
                    child: const Text('Show more'),
                  ),
                ),
              if (_showAllTasks)
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _showAllTasks = false),
                    child: const Text('Collapse'),
                  ),
                ),
            ],
          )
        : const SizedBox.shrink();
  }
}
