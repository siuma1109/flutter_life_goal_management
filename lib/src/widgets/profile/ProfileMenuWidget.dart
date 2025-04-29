import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/screens/Profile/completed_screen.dart';
import 'package:flutter_life_goal_management/src/screens/Profile/inbox_screen.dart';
import 'package:flutter_life_goal_management/src/widgets/projects/project_list_widget.dart';

class ProfileMenuWidget extends StatefulWidget {
  final int inboxTaskCount;
  final int finishedTaskCount;
  final User user;
  const ProfileMenuWidget({
    super.key,
    required this.inboxTaskCount,
    required this.finishedTaskCount,
    required this.user,
  });

  @override
  State<ProfileMenuWidget> createState() => _ProfileMenuWidgetState();
}

class _ProfileMenuWidgetState extends State<ProfileMenuWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToInbox() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InboxScreen(user: widget.user),
      ),
    );
  }

  void _navigateToCompleted() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CompletedScreen(user: widget.user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Inbox
        InkWell(
          onTap: _navigateToInbox,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.inbox,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text("Inbox", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Text(widget.inboxTaskCount.toString(),
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        // Completed
        InkWell(
          onTap: _navigateToCompleted,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text("Completed", style: TextStyle(fontSize: 16)),
                  ],
                ),
                Text(widget.finishedTaskCount.toString(),
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        Expanded(
          child: ProjectListWidget(user: widget.user),
        ),
      ],
    );
  }
}
