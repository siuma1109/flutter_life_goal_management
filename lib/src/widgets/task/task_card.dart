import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/comment.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
import 'package:flutter_life_goal_management/src/widgets/comment/comment_list_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/draggable_bottom_sheet_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/task/task_edit_form_widget.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(Task?)? onEdited;
  final bool showUser;
  const TaskCard({
    required this.task,
    this.onEdited,
    this.showUser = false,
    super.key,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late Task _task;
  bool _isLiked = false;
  int? _likesCount;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _likesCount = _task.likesCount;
    _isLiked = _task.isLiked ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => TaskEditFormWidget(
              task: _task,
              onRefresh: (Task? task) {
                if (task != null) {
                  widget.onEdited?.call(task);
                }
              },
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showUser)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        child: _task.user?.avatar == null
                            ? Icon(Icons.person)
                            : ClipOval(
                                child: Image.network(
                                  _task.user?.avatar ?? '',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.person),
                                ),
                              ),
                      ),
                      SizedBox(width: 8),
                      Text(_task.user?.name ?? ''),
                    ]),
                    Text(_task.createdAtFormatted),
                  ],
                ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration:
                          _task.isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (_task.user?.id == AuthService().getLoggedInUser()?.id)
                    Checkbox(
                      side: BorderSide(
                        color: TaskService().getPriorityColor(_task.priority),
                        width: 2.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: BorderSide(
                          color: TaskService().getPriorityColor(_task.priority),
                          width: 2.0,
                        ),
                      ),
                      activeColor:
                          TaskService().getPriorityColor(_task.priority),
                      value: _task.isChecked,
                      onChanged: (_) {
                        _task.isChecked = !_task.isChecked;

                        _updateTask(_task);
                      },
                    ),
                ],
              ),
              if (_task.subTasks != null && _task.subTasks!.isNotEmpty)
                Row(
                  children: [
                    Text(
                      "Sub Tasks",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "${_task.subTasks?.where((subTask) => subTask.isChecked).length ?? 0}/${_task.subTasks?.length ?? 0}",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () async {
                      if (await TaskService().likeTask(_task)) {
                        setState(() {
                          _isLiked = !_isLiked;
                          _likesCount = _likesCount! + (_isLiked ? 1 : -1);
                        });
                      }
                    },
                    color: _isLiked ? Colors.blue : Colors.grey,
                  ),
                  Text(_likesCount!.toString()),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () {
                      _showCommentsBottomSheet(context);
                    },
                  ),
                  Text(_task.commentsCount!.toString()),
                  // SizedBox(width: 16),
                  // IconButton(icon: Icon(Icons.share), onPressed: () {}),
                  // Text(_task.sharesCount!.toString()),
                ],
              ),
            ],
          ),
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
        print('task: ${_task.toJson()}');
        return DraggableBottomSheetWidget(
          minHeightFactor: 0.6,
          maxHeightFactor: 0.9,
          child: CommentListWidget(
            target: _task,
            onCommentSubmit: (Comment insertedComment) {
              setState(() {
                _task.commentsCount = (_task.commentsCount ?? 0) + 1;
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _updateTask(Task task) async {
    //print("task: ${task.toJson()}");
    await TaskService().updateTask(task);
    widget.onEdited?.call(task);
  }
}
