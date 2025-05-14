import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/common/shimmer_loading_widget.dart';

class TaskShimmerLoadingWidget extends StatelessWidget {
  const TaskShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: ShimmerLoadingWidget(height: 24, width: 160, borderRadius: 4),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: ShimmerLoadingWidget(height: 80),
            );
          },
        ),
      ],
    );
  }
}
