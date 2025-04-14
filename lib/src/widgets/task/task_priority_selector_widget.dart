import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';

class TaskPrioritySelectorWidget extends StatefulWidget {
  final int priority;
  final Function(int) onPriorityChanged;

  TaskPrioritySelectorWidget({
    super.key,
    required this.priority,
    required this.onPriorityChanged,
  });

  @override
  TaskPrioritySelectorWidgetState createState() =>
      TaskPrioritySelectorWidgetState();
}

class TaskPrioritySelectorWidgetState
    extends State<TaskPrioritySelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Priority', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final priority = index + 1;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  iconSize: 24,
                ),
                onPressed: () {
                  widget.onPriorityChanged(priority);
                  Navigator.of(context).pop();
                },
                child: Column(
                  children: [
                    Icon(Icons.flag,
                        color: TaskService().getPriorityColor(priority)),
                    Text(
                      'P$priority',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
