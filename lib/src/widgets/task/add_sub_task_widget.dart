import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_widget.dart';

class AddSubTaskWidget extends StatefulWidget {
  final Task task;
  final Function? onRefresh;
  const AddSubTaskWidget({super.key, required this.task, this.onRefresh});

  @override
  State<AddSubTaskWidget> createState() => _AddSubTaskWidgetState();
}

class _AddSubTaskWidgetState extends State<AddSubTaskWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAddSubtaskButton(),
      ],
    );
  }

  Widget _buildAddSubtaskButton() {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: AddTaskWidget(
                task: widget.task,
                isSubTask: true,
                onRefresh: (task) {
                  widget.onRefresh?.call(task);
                },
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 50,
              child: Icon(
                Icons.add,
                color: Colors.redAccent,
              ),
            ),
            Expanded(
              child: Text(
                "Add sub task",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
