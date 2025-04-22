import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/screens/Profile/edit_profile_screen.dart';

class ProfileInfoWidget extends StatefulWidget {
  final int taskCount;
  final User? user;
  const ProfileInfoWidget({
    super.key,
    required this.taskCount,
    required this.user,
  });

  @override
  State<ProfileInfoWidget> createState() => _ProfileInfoWidgetState();
}

class _ProfileInfoWidgetState extends State<ProfileInfoWidget> {
  User? _user;
  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40), // Use the icon as a child
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _user?.name ?? '',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(widget.taskCount.toString()),
                          Text('Tasks'),
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        children: [
                          Text('0'),
                          Text('Followers'),
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        children: [
                          Text('0'),
                          Text('Following'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // SizedBox(height: 16),
          // Text('This is a placeholder description for the user.',
          //     style: TextStyle(fontSize: 14)),
          SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(user: _user),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Edit Profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
