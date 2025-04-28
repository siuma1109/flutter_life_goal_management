import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/comment.dart';
import 'package:flutter_life_goal_management/src/models/feed.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/feed_service.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/comment/comment_list_item_widget.dart';

class CommentListWidget extends StatefulWidget {
  final Object target;
  final Function(Comment)? onCommentSubmit;

  const CommentListWidget({
    super.key,
    required this.target,
    this.onCommentSubmit,
  });

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  late dynamic _target;
  late List<Comment> _comments;
  int _page = 1;
  bool _hasMoreData = true;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _target = widget.target;
    if (_target is Task) {
      _target = _target as Task;
    } else if (_target is Feed) {
      _target = _target as Feed;
    }
    _comments = <Comment>[];
    _loadComments();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMoreData) {
        _loadComments();
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    Comment comment = Comment(
      id: 0,
      commentableType: _target is Task ? 'task' : 'feed',
      commentableId: _target.id,
      body: _commentController.text.trim(),
      userId: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_target is Task) {
      comment = await TaskService()
          .addComment(_target.id!, _commentController.text.trim());
    } else if (_target is Feed) {
      comment = await FeedService()
          .addComment(_target.id!, _commentController.text.trim());
    }

    setState(() {
      _comments = [
        comment,
        ..._comments,
      ];
    });

    if (widget.onCommentSubmit != null) {
      widget.onCommentSubmit!(comment);
      _commentController.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(bottom: 16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Column(
          children: [
            // 标题居中
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Comments',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 评论列表
            Expanded(
              child: _comments.isEmpty
                  ? const Center(child: Text('No comments yet'))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return CommentListItemWidget(
                            key: Key(comment.id.toString()), comment: comment);
                      },
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    child: AuthService().getLoggedInUser()?.avatar == null
                        ? Icon(Icons.person)
                        : ClipOval(
                            child: Image.network(
                              AuthService().getLoggedInUser()?.avatar ?? '',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.person),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      style: const TextStyle(fontSize: 14.0),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  TextButton(
                    onPressed: _submitComment,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    child: const Text('Post',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ));
  }

  void _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    if (_hasMoreData == false) return;

    try {
      final targetId = _target.id;
      if (targetId == null) {
        throw Exception('Target ID is null');
      }
      List<Comment> comments = <Comment>[];
      if (_target is Task) {
        comments = await TaskService().getComments(targetId, _page);
      } else if (_target is Feed) {
        comments = await FeedService().getComments(targetId, _page);
      }

      if (comments.isEmpty) {
        setState(() {
          _hasMoreData = false;
        });
      } else {
        setState(() {
          _comments.addAll(
              comments.where((t) => !_comments.any((tt) => tt.id == t.id)));
          _page++;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }
}
