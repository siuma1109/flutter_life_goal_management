import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/comment.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_row_widget.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  const CommentWidget({super.key, required this.comment});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  late Comment _comment;

  @override
  void initState() {
    super.initState();
    _comment = widget.comment;
  }

  @override
  Widget build(BuildContext context) {
    return TaskRowWidget(
      icon: Icon(Icons.person),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_comment.user!.name),
              Text(' | '),
              Text(_comment.createdAt.toString()),
            ],
          ),
          Wrap(
            children: [
              Text(
                _comment.body,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              )
            ],
          ),
        ],
      ),
    );
  }
}
