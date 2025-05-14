import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/common/shimmer_loading_widget.dart';

class TaskShimmerLoadingWidget extends StatelessWidget {
  final bool showTitle;
  final int itemCount;
  const TaskShimmerLoadingWidget({
    super.key,
    this.showTitle = true,
    this.itemCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child:
                  ShimmerLoadingWidget(height: 24, width: 160, borderRadius: 4),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: ShimmerLoadingWidget(height: 80),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
