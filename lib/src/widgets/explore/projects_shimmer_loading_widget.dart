import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/common/shimmer_loading_widget.dart';

class ProjectsShimmerLoadingWidget extends StatelessWidget {
  const ProjectsShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        ShimmerLoadingWidget(
                          height: 30,
                          width: 30,
                          margin: EdgeInsets.only(right: 10),
                        ),
                        ShimmerLoadingWidget(
                          height: 20,
                          width: 150,
                        ),
                      ],
                    ),
                    const ShimmerLoadingWidget(
                      height: 30,
                      width: 30,
                      margin: EdgeInsets.zero,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
