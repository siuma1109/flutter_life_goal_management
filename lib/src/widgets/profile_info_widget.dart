import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';

class ProfileInfoWidget extends StatefulWidget {
  const ProfileInfoWidget({super.key});

  @override
  State<ProfileInfoWidget> createState() => _ProfileInfoWidgetState();
}

class _ProfileInfoWidgetState extends State<ProfileInfoWidget> {
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
                        AuthService().getLoggedInUser()?.name ?? '',
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
                          Text('100'),
                          Text('Tasks'),
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        children: [
                          Text('100'),
                          Text('Followers'),
                        ],
                      ),
                      SizedBox(width: 16),
                      Column(
                        children: [
                          Text('150'),
                          Text('Following'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Text('This is a placeholder description for the user.',
              style: TextStyle(fontSize: 14)),
          SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
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
