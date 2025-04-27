import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/comment.dart';
import 'package:flutter_life_goal_management/src/models/feed.dart';
import 'package:flutter_life_goal_management/src/services/feed_service.dart';
import 'package:flutter_life_goal_management/src/widgets/comment/comment_list_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/draggable_bottom_sheet_widget.dart';

class FeedListItemWidget extends StatefulWidget {
  final Feed feed;

  const FeedListItemWidget({super.key, required this.feed});

  @override
  _FeedListItemWidgetState createState() => _FeedListItemWidgetState();
}

class _FeedListItemWidgetState extends State<FeedListItemWidget> {
  late Feed _feed;
  late int _likesCount;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _feed = widget.feed;
    _likesCount = _feed.likesCount ?? 0;
    _isLiked = _feed.isLiked ?? false;
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
            // TextButton(
            //   onPressed: () {},
            //   child: Text('View details'),
            // ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                    icon: Icon(Icons.thumb_up,
                        color: _isLiked ? Colors.blue : Colors.grey),
                    onPressed: () async {
                      if (await FeedService().likeFeed(_feed)) {
                        setState(() {
                          _isLiked = !_isLiked;
                          _likesCount = _likesCount! + (_isLiked ? 1 : -1);
                        });
                      }
                    }),
                Text(_likesCount!.toString()),
                IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () {
                      _showCommentsBottomSheet(context);
                    }),
                Text(_feed.commentsCount!.toString()),
                // IconButton(icon: Icon(Icons.share), onPressed: () {}),
                // Text(_feed.sharesCount!.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return DraggableBottomSheetWidget(
          minHeightFactor: 0.6,
          maxHeightFactor: 0.9,
          child: CommentListWidget(
            target: _feed,
            onCommentSubmit: (Comment insertedComment) {
              setState(() {
                _feed.commentsCount = (_feed.commentsCount ?? 0) + 1;
              });
            },
          ),
        );
      },
    );
  }
}
