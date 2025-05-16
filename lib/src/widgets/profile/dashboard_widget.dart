import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/common/shimmer_loading_widget.dart';

class DashboardWidget extends StatefulWidget {
  final int finishedTaskCount;
  final int pendingTaskCount;
  final bool isInitialLoading;
  final bool isLoading;
  const DashboardWidget({
    super.key,
    required this.finishedTaskCount,
    required this.pendingTaskCount,
    required this.isInitialLoading,
    required this.isLoading,
  });

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard",
              style: TextStyle(
                color: Colors.black87,
                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.isInitialLoading
                    ? ShimmerLoadingWidget(
                        height: 100,
                        width: 140,
                      )
                    : Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: widget.isLoading
                                  ? ShimmerLoadingWidget(
                                      height: 20,
                                      width: 24,
                                    )
                                  : Text(
                                      widget.finishedTaskCount.toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            Text(
                              "Finished Tasks",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                widget.isInitialLoading
                    ? ShimmerLoadingWidget(
                        height: 100,
                        width: 140,
                      )
                    : Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: widget.isLoading
                                  ? ShimmerLoadingWidget(
                                      height: 20,
                                      width: 24,
                                    )
                                  : Text(
                                      widget.pendingTaskCount.toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            Text(
                              "Pending Tasks",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
