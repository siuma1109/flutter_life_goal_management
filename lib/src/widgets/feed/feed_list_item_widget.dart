import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/feed.dart';

class FeedListItemWidget extends StatefulWidget {
  final Feed feed;

  const FeedListItemWidget({super.key, required this.feed});

  @override
  _FeedListItemWidgetState createState() => _FeedListItemWidgetState();
}

class _FeedListItemWidgetState extends State<FeedListItemWidget> {
  late Feed _feed;

  @override
  void initState() {
    super.initState();
    _feed = widget.feed;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: _feed.user!.avatar == null
                          ? Icon(Icons.person)
                          : ClipOval(
                              child: Image.network(
                                _feed.user!.avatar!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.person),
                              ),
                            ),
                    ),
                    SizedBox(width: 8),
                    Text(_feed.user!.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(width: 8),
                Row(
                  children: [
                    Text(_feed.createdAtFormatted),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            if (_feed.body != null) Text(_feed.body!),
            TextButton(
              onPressed: () {},
              child: Text('View details'),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(icon: Icon(Icons.thumb_up), onPressed: () {}),
                Text(_feed.likesCount!.toString()),
                IconButton(icon: Icon(Icons.comment), onPressed: () {}),
                Text(_feed.commentsCount!.toString()),
                IconButton(icon: Icon(Icons.share), onPressed: () {}),
                Text(_feed.sharesCount!.toString()),
              ],
            ),
          ],
        ),
      ),
    );
    ;
  }
}
