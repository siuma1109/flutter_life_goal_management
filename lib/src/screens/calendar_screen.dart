import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/task_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
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
  late Map<DateTime, List<Task>> _tasksByDay = {};
  List<Task> _selectedTasks = <Task>[];
  late DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  StreamSubscription? _taskChangedSubscription;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTasksSource();

    _taskChangedSubscription = TaskBroadcast().taskChangedStream.listen((_) {
      _loadTasksSource();
    });
    _selectedTasks = _getTasksForDay(_selectedDay);
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
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     ElevatedButton(
            //       onPressed: () {
            //         setState(() {
            //           _calendarController.view = CalendarView.month;
            //         });
            //       },
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor:
            //             _calendarController.view == CalendarView.month
            //                 ? Theme.of(context).colorScheme.primary
            //                 : Colors.white,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.only(
            //             topLeft: Radius.circular(4),
            //             bottomLeft: Radius.circular(4),
            //           ),
            //         ),
            //       ),
            //       child: Text('Month',
            //           style: TextStyle(
            //               color: _calendarController.view == CalendarView.month
            //                   ? Colors.white
            //                   : Colors.black)),
            //     ),
            //     SizedBox(width: 2),
            //     ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor:
            //             _calendarController.view == CalendarView.week
            //                 ? Theme.of(context).colorScheme.primary
            //                 : Colors.white,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(0),
            //         ),
            //       ),
            //       onPressed: () {
            //         setState(() {
            //           _calendarController.view = CalendarView.week;
            //         });
            //       },
            //       child: Text('Week',
            //           style: TextStyle(
            //               color: _calendarController.view == CalendarView.week
            //                   ? Colors.white
            //                   : Colors.black)),
            //     ),
            //     SizedBox(width: 2),
            //     ElevatedButton(
            //       onPressed: () {
            //         setState(() {
            //           _calendarController.view = CalendarView.day;
            //         });
            //       },
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor:
            //             _calendarController.view == CalendarView.day
            //                 ? Theme.of(context).colorScheme.primary
            //                 : Colors.white,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(0),
            //         ),
            //       ),
            //       child: Text('Day',
            //           style: TextStyle(
            //               color: _calendarController.view == CalendarView.day
            //                   ? Colors.white
            //                   : Colors.black)),
            //     ),
            //     SizedBox(width: 2),
            //     ElevatedButton(
            //       onPressed: () {
            //         setState(() {
            //           _calendarController.view = CalendarView.schedule;
            //         });
            //       },
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor:
            //             _calendarController.view == CalendarView.schedule
            //                 ? Theme.of(context).colorScheme.primary
            //                 : Colors.white,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.only(
            //             topRight: Radius.circular(4),
            //             bottomRight: Radius.circular(4),
            //           ),
            //         ),
            //       ),
            //       child: Text('Schedule',
            //           style: TextStyle(
            //               color:
            //                   _calendarController.view == CalendarView.schedule
            //                       ? Colors.white
            //                       : Colors.black)),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 16),

            TableCalendar(
              firstDay: DateTime.now().subtract(Duration(days: 365 * 10)),
              lastDay: DateTime.now().add(Duration(days: 365 * 10)),
              focusedDay: DateTime.now(),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(selectedDay, _selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  _loadTasksSource();
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: (day) {
                return _getTasksForDay(day);
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
              child: _selectedTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 100,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          Text('No tasks',
                              style: Theme.of(context).textTheme.headlineLarge),
                        ],
                      ),
                    )
                  : TaskListWidget(tasks: _selectedTasks),
              // : ListView.builder(
              //     // Generate a unique key based on the task list length/content
              //     key: ValueKey(
              //         'taskList-${_tasksByDay.length}-${DateTime.now().millisecondsSinceEpoch}'),
              //     itemCount: _selectedTasks.length,
              //     itemBuilder: (context, index) {
              //       return ListTile(
              //         title: Text('Task ${_selectedTasks[index].title}'),
              //         key: ValueKey('task-${_selectedTasks[index].id}'),
              //       );
              //     },
              //   ),
            )
          ])),
      floatingActionButton: AddTaskFloatingButtonWidget(
        key: ValueKey('calendarAddTaskButton'),
      ),
    );
  }

  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const List<int> daysInMonth = <int>[
      31,
      -1,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    ];
    return daysInMonth[month - 1];
  }

  Future<void> _loadTasksSource() async {
    try {
      final tasks = await TaskService()
          .getTasksByYearAndMonth(_focusedDay.year, _focusedDay.month);

      final Map<DateTime, List<Task>> tasksByDay = {};

      for (Task task in tasks) {
        final taskDate =
            DateFormat('yyyy-MM-dd').parse(task.startDate!.toIso8601String());
        // Normalize date to remove time component for proper comparison
        final normalizedDate =
            DateTime(taskDate.year, taskDate.month, taskDate.day);

        if (tasksByDay[normalizedDate] == null) {
          tasksByDay[normalizedDate] = [];
        }
        tasksByDay[normalizedDate]!.add(task);
      }

      if (mounted) {
        setState(() {
          _tasksByDay = tasksByDay;
          _selectedTasks = _getTasksForDay(_selectedDay);
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    // Normalize date to remove time component for proper comparison
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return _tasksByDay[normalizedDate] ?? [];
  }
}
