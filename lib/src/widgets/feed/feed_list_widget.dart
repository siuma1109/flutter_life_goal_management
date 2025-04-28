import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/feed.dart';
import 'package:flutter_life_goal_management/src/widgets/feed/feed_list_item_widget.dart';

class FeedListWidget extends StatefulWidget {
  final List<Feed> feeds;
  const FeedListWidget({super.key, required this.feeds});

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
    return Column(
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
      ],
    );
  }

  Widget _buildEmptyView() {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: const Text(
        'No activity yet',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
