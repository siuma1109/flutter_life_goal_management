import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_shimmer_loading_widget.dart';

class ExploreTasksShimmerLoadingWidget extends StatelessWidget {
  const ExploreTasksShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const TaskShimmerLoadingWidget(
      showTitle: false,
      itemCount: 6,
    );
  }
}
