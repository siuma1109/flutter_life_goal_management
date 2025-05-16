import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/models/task_date_count.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_list_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_shimmer_loading_widget.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final String title;

  const CalendarScreen({super.key, required this.title});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<String>> _tasksByDay = {};
  late DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  StreamSubscription? _taskChangedSubscription;
  Map<String, int> _pages = <String, int>{};
  Map<String, bool> _hasMoreData = <String, bool>{};
  Map<String, List<Task>> _tasks = <String, List<Task>>{};
  LoadingState _loadingState = LoadingState.idle;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(_focusedDay);
    _initData();
    _taskChangedSubscription =
        TaskBroadcast().taskChangedStream.listen((Task? task) {
      if (task == null) {
        // If task is null, it might be deleted, need to refresh data
        _refreshAllData();
        return;
      }

      // Handle task changes
      if (task.parentId == null) {
        // If it's a main task (no parent task)
        _handleMainTaskChanged(task);
      } else {
        // If it's a subtask
        _handleSubTaskChanged(task);
      }
    });
    // Trigger the loading indicator programmatically after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  void dispose() {
    _taskChangedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            TableCalendar(
              firstDay: DateTime.now().subtract(Duration(days: 365 * 10)),
              lastDay: DateTime.now().add(Duration(days: 365 * 10)),
              focusedDay: _focusedDay,
              onDaySelected: (selectedDay, focusedDay) {
                final normalizedSelectedDay = _normalizeDate(selectedDay);
                final normalizedFocusedDay = _normalizeDate(focusedDay);

                if (!isSameDay(normalizedSelectedDay, _selectedDay)) {
                  setState(() {
                    _selectedDay = normalizedSelectedDay;
                    _focusedDay = normalizedFocusedDay;
                  });

                  final selectedDayKey = _dateToKey(normalizedSelectedDay);
                  if (_tasks[selectedDayKey] == null) {
                    _loadTasksForDay(normalizedSelectedDay);
                  }
                }
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = _normalizeDate(focusedDay);
                });
                _loadTasksSource();
              },
              eventLoader: (day) {
                return getTasksForDay(day);
              },
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDay, _normalizeDate(day)),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
            ),
            Expanded(
              child: _buildTaskList(),
            )
          ])),
      floatingActionButton: AddTaskFloatingButtonWidget(
        key: ValueKey('calendarAddTaskButton'),
      ),
    );
  }

  Widget _buildTaskList() {
    final selectedDayKey = _dateToKey(_selectedDay);

    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!scrollInfo.metrics.atEdge) return false;
          if (scrollInfo.metrics.pixels == 0) return false;

          if (_loadingState == LoadingState.idle) {
            _loadTasksForDay(_selectedDay);
          }
          return true;
        },
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: refreshTasks,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_loadingState == LoadingState.loading &&
                    (_tasks[selectedDayKey] == null ||
                        _tasks[selectedDayKey]!.isEmpty))
                  TaskShimmerLoadingWidget(
                    showTitle: false,
                  )
                else
                  TaskListWidget(
                    tasks: _tasks[selectedDayKey] ?? [],
                  ),
                if (_loadingState == LoadingState.loadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshTasks() async {
    final selectedDayKey = _dateToKey(_selectedDay);
    setState(() {
      _pages[selectedDayKey] = 1;
      _hasMoreData[selectedDayKey] = true;
      _tasks[selectedDayKey] = <Task>[];
    });
    await _loadTasksSource();
    await _loadTasksForDay(_selectedDay);
  }

  Future<void> _initData() async {
    await _loadTasksSource();
    await _loadTasksForDay(_selectedDay);
  }

  Future<void> _loadTasksSource() async {
    if (_loadingState != LoadingState.idle) return;

    setState(() {
      _loadingState = LoadingState.loading;
    });

    try {
      final result = await TaskService()
          .getTasksByYearAndMonthCount(_focusedDay.year, _focusedDay.month);

      final Map<DateTime, List<String>> tasksByDay = {};

      for (TaskDateCount row in result) {
        final taskDate = DateFormat('yyyy-MM-dd').parse(row.date);
        final normalizedDate = _normalizeDate(taskDate);

        if (tasksByDay[normalizedDate] == null) {
          tasksByDay[normalizedDate] = [];
        }
        for (int i = 0; i < row.count; i++) {
          tasksByDay[normalizedDate]!.add(i.toString());
        }
      }

      // Handle date ranges from existing tasks
      for (final dateKey in _tasks.keys) {
        for (final task in _tasks[dateKey]!) {
          if (task.startDate != null && task.endDate != null) {
            // Get all dates in the task's range
            List<DateTime> taskDates = _getTaskDateRange(task);

            // Add to calendar for each date in range
            for (final date in taskDates) {
              // Only add if in current month view
              if (date.year == _focusedDay.year &&
                  date.month == _focusedDay.month) {
                if (tasksByDay[date] == null) {
                  tasksByDay[date] = [];
                }
                // Only add if not already counted for this date
                if (!tasksByDay[date]!.contains(task.id.toString())) {
                  tasksByDay[date]!.add(task.id.toString());
                }
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _tasksByDay = tasksByDay;
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }

    if (mounted) {
      setState(() {
        _loadingState = LoadingState.idle;
      });
    }
  }

  Future<void> _loadTasksForDay(DateTime day) async {
    if (_loadingState != LoadingState.idle) return;

    final dayKey = _dateToKey(day);

    if (_hasMoreData[dayKey] == false) return;

    setState(() {
      _loadingState = _tasks[dayKey] == null || _tasks[dayKey]!.isEmpty
          ? LoadingState.loading
          : LoadingState.loadingMore;
    });

    _hasMoreData[dayKey] = _hasMoreData[dayKey] ?? true;
    _pages[dayKey] = _pages[dayKey] ?? 1;
    _tasks[dayKey] = _tasks[dayKey] ?? <Task>[];

    try {
      final normalizedDay = _normalizeDate(day);
      final tasks = await TaskService()
          .getTasksByDate(normalizedDay, _pages[dayKey] ?? 1);

      if (mounted) {
        setState(() {
          if (tasks.isEmpty) {
            _hasMoreData[dayKey] = false;
          } else {
            _hasMoreData[dayKey] = true;
            _pages[dayKey] = _pages[dayKey]! + 1;
          }

          // Process tasks to handle date ranges
          for (Task task in tasks) {
            // Skip if task already exists in the list
            if (_tasks[dayKey]!.any((t) => t.id == task.id)) continue;

            // Add to current day's list
            _tasks[dayKey]!.add(task);

            // If task has date range, make sure it appears on all relevant days
            if (task.endDate != null &&
                task.startDate != null &&
                !task.startDate!.isAtSameMomentAs(task.endDate!)) {
              List<DateTime> taskDates = _getTaskDateRange(task);

              // Skip the first date since we already added it above
              for (int i = 1; i < taskDates.length; i++) {
                final otherDayKey = _dateToKey(taskDates[i]);

                // Initialize the day's task list if needed
                _tasks[otherDayKey] = _tasks[otherDayKey] ?? <Task>[];

                // Add task to this day if not already there
                if (!_tasks[otherDayKey]!.any((t) => t.id == task.id)) {
                  _tasks[otherDayKey]!.add(task);
                }

                // Update calendar display for this day
                _updateTasksCountInCalendar(taskDates[i]);
              }
            }
          }

          _loadingState = LoadingState.idle;
        });
      }
    } catch (e) {
      print('Error loading tasks for day: $e');
      if (mounted) {
        setState(() {
          _loadingState = LoadingState.idle;
        });
      }
    }
  }

  List<String> getTasksForDay(DateTime day) {
    final normalizedDate = _normalizeDate(day);
    return _tasksByDay[normalizedDate] ?? [];
  }

  void _handleMainTaskChanged(Task task) {
    if (task.startDate == null) return;

    // Get the key for the task date range
    List<DateTime> taskDates = _getTaskDateRange(task);
    List<String> taskDateKeys =
        taskDates.map((date) => _dateToKey(_normalizeDate(date))).toList();

    // Find the task position in all dates (date might have changed)
    List<String> oldDateKeys = [];

    // Look for task in dates that are not in the new date range
    for (final dateKey in _tasks.keys) {
      if (!taskDateKeys.contains(dateKey)) {
        final taskIndex = _tasks[dateKey]!.indexWhere((t) => t.id == task.id);
        if (taskIndex != -1) {
          // Found task in a date outside the new range, need to remove
          setState(() {
            _tasks[dateKey]!.removeAt(taskIndex);
          });
          oldDateKeys.add(dateKey);
        }
      }
    }

    // Add task to all dates in the range
    for (final taskDateKey in taskDateKeys) {
      // Check if there's a task list for this date
      if (_tasks.containsKey(taskDateKey)) {
        final existingTaskIndex =
            _tasks[taskDateKey]!.indexWhere((t) => t.id == task.id);

        setState(() {
          if (existingTaskIndex != -1) {
            // If task already exists, replace it
            _tasks[taskDateKey]![existingTaskIndex] = task;
          } else {
            // If task doesn't exist, add it to the top
            _tasks[taskDateKey]!.insert(0, task);
          }
        });
      } else {
        // Create new task list for this date
        setState(() {
          _tasks[taskDateKey] = [task];
        });
      }

      // Update task count in calendar view for this date
      _updateTasksCountInCalendar(taskDates[taskDateKeys.indexOf(taskDateKey)]);
    }

    // Update old dates that are no longer in the range
    for (final oldDateKey in oldDateKeys) {
      final oldDateParts = oldDateKey.split('-');
      if (oldDateParts.length == 3) {
        final oldDate = DateTime(int.parse(oldDateParts[0]),
            int.parse(oldDateParts[1]), int.parse(oldDateParts[2]));
        _updateTasksCountInCalendar(oldDate);
      }
    }
  }

  // Get all dates in the task's date range
  List<DateTime> _getTaskDateRange(Task task) {
    List<DateTime> dates = [];

    if (task.startDate == null) {
      return dates;
    }

    DateTime startDate = _normalizeDate(task.startDate!);
    DateTime endDate =
        task.endDate != null ? _normalizeDate(task.endDate!) : startDate;

    // Ensure endDate is not before startDate
    if (endDate.isBefore(startDate)) {
      endDate = startDate;
    }

    // Add all dates in the range
    for (DateTime date = startDate;
        !date.isAfter(endDate);
        date = date.add(const Duration(days: 1))) {
      dates.add(date);
    }

    return dates;
  }

  void _handleSubTaskChanged(Task task) {
    // Iterate through all date task lists to find parent task
    for (final dateKey in _tasks.keys) {
      final parentTaskIndex =
          _tasks[dateKey]!.indexWhere((t) => t.id == task.parentId);

      if (parentTaskIndex != -1) {
        // Found the parent task
        Task parentTask = _tasks[dateKey]![parentTaskIndex];

        // Check if subtask already exists
        final existingSubTaskIndex =
            parentTask.subTasks.indexWhere((t) => t.id == task.id);

        setState(() {
          if (existingSubTaskIndex != -1) {
            // If subtask already exists, replace it
            parentTask.subTasks[existingSubTaskIndex] = task;
          } else {
            // If subtask doesn't exist, add to subtasks list
            parentTask.subTasks.insert(0, task);
          }

          // Update parent task
          _tasks[dateKey]![parentTaskIndex] = parentTask;
        });

        break; // Exit loop after finding and processing
      }
    }
  }

  void _updateTasksCountInCalendar(DateTime taskDate) {
    final normalizedDate = _normalizeDate(taskDate);

    // Check if date is in current month
    if (normalizedDate.year == _focusedDay.year &&
        normalizedDate.month == _focusedDay.month) {
      // Get task count for this date
      final dayKey = _dateToKey(normalizedDate);
      int taskCount = 0;

      if (_tasks.containsKey(dayKey)) {
        taskCount = _tasks[dayKey]!.length;
      }

      setState(() {
        if (taskCount > 0) {
          // If there are tasks, update the task list for this date
          _tasksByDay[normalizedDate] =
              List.generate(taskCount, (i) => i.toString());
        } else {
          // If there are no tasks, remove the task list for this date
          _tasksByDay.remove(normalizedDate);
        }
      });
    }
  }

  Future<void> _refreshAllData() async {
    // Reload data for current month
    await _loadTasksSource();

    // If viewing tasks for a specific date, refresh tasks for that date
    final selectedDayKey = _dateToKey(_selectedDay);
    if (_tasks.containsKey(selectedDayKey)) {
      setState(() {
        _pages[selectedDayKey] = 1;
        _hasMoreData[selectedDayKey] = true;
        _tasks[selectedDayKey] = <Task>[];
      });

      await _loadTasksForDay(_selectedDay);
    }
  }
}

enum LoadingState { idle, loading, loadingMore }
