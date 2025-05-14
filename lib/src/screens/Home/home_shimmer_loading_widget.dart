import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/feed/feed_shimmer_loading_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_shimmer_loading_widget.dart';

class HomeShimmerLoadingWidget extends StatelessWidget {
  const HomeShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: const [
          TaskShimmerLoadingWidget(),
          FeedShimmerLoadingWidget(),
        ],
      ),
    );
  }
}
