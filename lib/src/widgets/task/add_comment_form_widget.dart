import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/comment.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';

class AddCommentFormWidget extends StatefulWidget {
  final Task task;
  final Function(Comment) onCommentAdded;
  const AddCommentFormWidget({
    super.key,
    required this.task,
    required this.onCommentAdded,
  });

  @override
  _AddCommentFormWidgetState createState() => _AddCommentFormWidgetState();
}

class _AddCommentFormWidgetState extends State<AddCommentFormWidget> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _commentController.text = '';
    _commentFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Add a comment',
            ),
            focusNode: _commentFocusNode,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final Comment addedComment = await TaskService()
                        .addComment(widget.task.id!, _commentController.text);
                    print("addedComment: ${addedComment.toJson()}");
                    widget.onCommentAdded(addedComment);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print('error: ${e.toString()}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                  setState(() {
                    _isLoading = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
