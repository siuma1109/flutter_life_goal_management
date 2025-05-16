import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/screens/profile_screen.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/user_service.dart';

class UserListItemWidget extends StatefulWidget {
  final User user;
  final User seeingUser;

  const UserListItemWidget({
    super.key,
    required this.user,
    required this.seeingUser,
  });

  @override
  _UserListItemWidgetState createState() => _UserListItemWidgetState();
}

class _UserListItemWidgetState extends State<UserListItemWidget> {
  String _followerString = '';
  @override
  void initState() {
    super.initState();
    _followerString =
        widget.user.followersCount != null && widget.user.followersCount! > 1
            ? 'followers'
            : 'follower';
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //print('widget.user.name: ${widget.user.name}');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(user: widget.user)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: widget.user.avatar == null
                      ? Icon(Icons.person)
                      : ClipOval(
                          child: Image.network(
                            widget.user.avatar!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.person),
                          ),
                        ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user.name),
                    Text(
                      "${widget.user.followersCount} ${_followerString}",
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                if (widget.seeingUser.id == AuthService().getLoggedInUser()?.id)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.user.isFollowed == 0
                          ? Colors.black
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _followUser();
                    },
                    child: Text(
                      widget.user.isFollowed == 0 ? 'Follow' : 'Following',
                      style: TextStyle(
                        color: widget.user.isFollowed == 0
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _followUser() async {
    setState(() {
      widget.user.followersCount = widget.user.isFollowed == 0
          ? widget.user.followersCount! + 1
          : widget.user.followersCount! - 1;
      widget.user.isFollowed = widget.user.isFollowed == 0 ? 1 : 0;
    });
    await UserService().followUser(widget.user);
  }
}
