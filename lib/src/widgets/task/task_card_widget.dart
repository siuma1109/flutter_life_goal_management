import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_edit_form_widget.dart';

class TaskCardWidget extends StatefulWidget {
  final Task task;

  const TaskCardWidget({super.key, required this.task});

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  Task? _task;
  late TaskService _taskService;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _taskService = TaskService();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to task detail view
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => TaskEditFormWidget(
              task: _task!,
              onRefresh: (updatedTask) {
                if (updatedTask != null) {
                  setState(() {
                    _task = updatedTask;
                  });
                }
              }),
        );
      },
      child: Card(
        elevation: 0,
        margin: EdgeInsets.all(4),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: AspectRatio(
          aspectRatio: 1, // Square aspect ratio like Instagram
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getPriorityColorLight(_task!.priority),
                  _getPriorityColor(_task!.priority),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        _task!.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      // Description if available
                      if (_task!.description != null &&
                          _task!.description!.isNotEmpty)
                        Expanded(
                          child: Text(
                            _task!.description!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // Checked indicator
                if (_task!.isChecked)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.check,
                        color: _getPriorityColor(_task!.priority),
                        size: 16,
                      ),
                    ),
                  ),
                // Date indicator if available
                if (_task!.startDate != null || _task!.endDate != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _getDateText(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    return _taskService.getPriorityColor(priority);
  }

  Color _getPriorityColorLight(int priority) {
    switch (priority) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.lightBlue;
      case 4:
        return Colors.grey[400]!;
      default:
        return Colors.grey[300]!;
    }
  }

  String _getDateText() {
    if (_task!.endDate != null) {
      return '${_task!.endDate!.day}/${_task!.endDate!.month}';
    } else if (_task!.startDate != null) {
      return '${_task!.startDate!.day}/${_task!.startDate!.month}';
    }
    return '';
  }
}
