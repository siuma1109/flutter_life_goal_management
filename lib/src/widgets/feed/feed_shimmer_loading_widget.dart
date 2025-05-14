import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_life_goal_management/src/widgets/common/shimmer_loading_widget.dart';

class FeedShimmerLoadingWidget extends StatelessWidget {
  const FeedShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: ShimmerLoadingWidget(height: 24, width: 120, borderRadius: 4),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ShimmerLoadingWidget(
                        height: 40,
                        width: 40,
                        borderRadius: 20,
                        margin: EdgeInsets.only(right: 8.0),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerLoadingWidget(
                            height: 12,
                            width: 100,
                            margin: EdgeInsets.only(bottom: 4.0),
                          ),
                          ShimmerLoadingWidget(
                            height: 10,
                            width: 60,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ShimmerLoadingWidget(height: 120),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      ShimmerLoadingWidget(
                        height: 20,
                        width: 20,
                        borderRadius: 10,
                        margin: EdgeInsets.only(right: 4.0),
                      ),
                      ShimmerLoadingWidget(
                        height: 10,
                        width: 30,
                        margin: EdgeInsets.only(right: 16.0),
                      ),
                      ShimmerLoadingWidget(
                        height: 20,
                        width: 20,
                        borderRadius: 10,
                        margin: EdgeInsets.only(right: 4.0),
                      ),
                      ShimmerLoadingWidget(
                        height: 10,
                        width: 30,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class FeedItemShimmerLoadingWidget extends StatelessWidget {
  const FeedItemShimmerLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 100,
                      margin: const EdgeInsets.only(bottom: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    Container(
                      height: 10,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  height: 20,
                  width: 20,
                  margin: const EdgeInsets.only(right: 4.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 10,
                  width: 30,
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Container(
                  height: 20,
                  width: 20,
                  margin: const EdgeInsets.only(right: 4.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 10,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
