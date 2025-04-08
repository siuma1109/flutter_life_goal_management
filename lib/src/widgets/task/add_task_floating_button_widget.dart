import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_widget.dart';

class AddTaskFloatingButtonWidget extends StatefulWidget {
  final VoidCallback? onRefresh;

  const AddTaskFloatingButtonWidget({
    super.key,
    this.onRefresh,
  });

  @override
  State<AddTaskFloatingButtonWidget> createState() =>
      _AddTaskFloatingButtonWidgetState();
}

class _AddTaskFloatingButtonWidgetState
    extends State<AddTaskFloatingButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        var result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          useRootNavigator: true,
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: const AddTaskWidget(),
            );
          },
        );

        if (result == true) {
          widget.onRefresh?.call();
        }
      },
      child: const Icon(Icons.add),
    );
  }
}
