import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/comment.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_comment_form_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/comment_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_row_widget.dart';

class CommentListWidget extends StatefulWidget {
  final Task task;
  const CommentListWidget({super.key, required this.task});

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  Task? task;
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    task = widget.task;
    _loadComments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadComments() async {
    try {
      final taskId = task!.id;
      if (taskId == null) {
        throw Exception('Task ID is null');
      }
      final comments = await TaskService().getComments(taskId);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadComments();
      },
      child: Container(
        alignment: Alignment.centerLeft,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TaskRowWidget(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    builder: (context) => AddCommentFormWidget(
                      task: widget.task,
                      onCommentAdded: (Comment insertedComment) {
                        print(
                            "callback insertedComment: ${insertedComment.toJson()}");
                        setState(() {
                          _comments = List<Comment>.from([
                            insertedComment,
                            ..._comments,
                          ]);
                        });
                        print("comments: ${_comments.map((e) => e.toJson())}");
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Comments (${_comments.length})'),
                    Row(
                      children: [
                        Icon(Icons.add),
                        Text('Add Comment'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _comments.isEmpty
                    ? Text('No comments yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ))
                    : ListView.builder(
                        key: UniqueKey(),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return CommentWidget(comment: _comments[index]);
                        },
                      ),
              ),
            ]),
      ),
    );
  }
}
