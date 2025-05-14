import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/explore/explore_tasks_shimmer_loading_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/explore/projects_shimmer_loading_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/explore/users_shimmer_loading_widget.dart';

class ExploreShimmerLoadingWidget extends StatelessWidget {
  final int activeTab;

  const ExploreShimmerLoadingWidget({
    super.key,
    this.activeTab = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          if (activeTab == 0)
            const UsersShimmerLoadingWidget()
          else if (activeTab == 1)
            const ProjectsShimmerLoadingWidget()
          else
            const ExploreTasksShimmerLoadingWidget(),
        ],
      ),
    );
  }
}
