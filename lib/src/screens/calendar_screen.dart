import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/models/task_date_count.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_list_widget.dart';
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

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(_focusedDay);
    _initData();
    // _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
    //   _loadTasksSource();
    //   _loadTasksForDay(_selectedDay);
    // });
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
          onRefresh: refreshTasks,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_loadingState == LoadingState.loading &&
                    (_tasks[selectedDayKey] == null ||
                        _tasks[selectedDayKey]!.isEmpty))
                  const Center(child: CircularProgressIndicator())
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

          _tasks[dayKey]!.addAll(
              tasks.where((t) => !_tasks[dayKey]!.any((tt) => tt.id == t.id)));

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
}

enum LoadingState { idle, loading, loadingMore }
