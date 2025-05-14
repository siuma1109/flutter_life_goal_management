import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/feed.dart';
import 'package:flutter_life_goal_management/src/widgets/feed/feed_list_item_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/feed/feed_shimmer_loading_widget.dart';

class FeedListWidget extends StatefulWidget {
  final List<Feed> feeds;
  final bool isLoading;
  final bool isRefreshing;

  const FeedListWidget({
    super.key,
    required this.feeds,
    this.isLoading = false,
    this.isRefreshing = false,
  });

  @override
  _FeedListWidgetState createState() => _FeedListWidgetState();
}

class _FeedListWidgetState extends State<FeedListWidget> {
  late List<Feed> _feeds;

  @override
  void initState() {
    super.initState();
    _feeds = widget.feeds;
  }

  @override
  void didUpdateWidget(FeedListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feeds != oldWidget.feeds) {
      setState(() {
        _feeds = widget.feeds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isRefreshing
        ? const FeedShimmerLoadingWidget()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Activity Feed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _feeds.isEmpty
                  ? _buildEmptyView()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _feeds.length,
                      itemBuilder: (context, index) {
                        return FeedListItemWidget(
                            key: Key(_feeds[index].id.toString()),
                            feed: _feeds[index]);
                      },
                    ),
              if (widget.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          );
  }

  Widget _buildEmptyView() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_activity_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No activity yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New activity will be displayed here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
