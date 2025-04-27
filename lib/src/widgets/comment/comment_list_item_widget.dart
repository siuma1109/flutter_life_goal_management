import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/comment.dart';

class CommentListItemWidget extends StatefulWidget {
  final Comment comment;

  const CommentListItemWidget({super.key, required this.comment});

  @override
  State<CommentListItemWidget> createState() => _CommentListItemWidgetState();
}

class _CommentListItemWidgetState extends State<CommentListItemWidget> {
  late Comment _comment;

  @override
  void initState() {
    super.initState();
    _comment = widget.comment;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Stack(
        children: [
          Positioned(
            top: -15,
            child: Container(
              width: 60,
              height: 7,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 18.0,
                child: Icon(Icons.person), // Placeholder user icon
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _comment.user!.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          _comment.createdAtFormatted,
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(_comment.body),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
