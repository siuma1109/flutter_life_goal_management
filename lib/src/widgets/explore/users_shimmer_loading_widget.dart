import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/common/shimmer_loading_widget.dart';

class UsersShimmerLoadingWidget extends StatelessWidget {
  const UsersShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    const ShimmerLoadingWidget(
                      height: 50,
                      width: 50,
                      borderRadius: 25,
                      margin: EdgeInsets.only(right: 16.0),
                    ),
                    Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerLoadingWidget(
                                  height: 14,
                                  width: 140,
                                ),
                                ShimmerLoadingWidget(
                                  height: 12,
                                  width: 120,
                                ),
                              ],
                            ),
                            ShimmerLoadingWidget(
                              height: 40,
                              width: 80,
                            ),
                          ]),
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
