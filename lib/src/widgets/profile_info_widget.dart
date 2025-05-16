import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/user_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/screens/Profile/edit_profile_screen.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/user_service.dart';
import 'package:flutter_life_goal_management/src/widgets/common/shimmer_loading_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/users/user_details_widget.dart';

class ProfileInfoWidget extends StatefulWidget {
  final int taskCount;
  final bool isInitialLoading;
  final bool isLoading;
  final TabController tabController;
  final User user;

  const ProfileInfoWidget({
    super.key,
    required this.taskCount,
    required this.isInitialLoading,
    required this.isLoading,
    required this.tabController,
    required this.user,
  });

  @override
  State<ProfileInfoWidget> createState() => _ProfileInfoWidgetState();
}

class _ProfileInfoWidgetState extends State<ProfileInfoWidget> {
  User? _user;
  StreamSubscription? _userChangedSubscription;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    if (_user?.id == AuthService().getLoggedInUser()?.id) {
      _userChangedSubscription = UserBroadcast().userChangedStream.listen((_) {
        _loadUser();
      });
    }
  }

  @override
  void dispose() {
    _userChangedSubscription?.cancel();
    super.dispose();
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
                child: _user?.avatar == null
                    ? Icon(Icons.person, size: 50)
                    : ClipOval(
                        child: Image.network(
                          _user?.avatar ?? '',
                          width: 44,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.person, size: 50),
                        ),
                      ),
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
                      InkWell(
                          onTap: () {
                            widget.tabController.animateTo(1);
                          },
                          child: widget.isInitialLoading
                              ? Column(
                                  children: [
                                    ShimmerLoadingWidget(
                                      height: 14,
                                      width: 22,
                                    ),
                                    ShimmerLoadingWidget(
                                      height: 14,
                                      width: 44,
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    widget.isLoading
                                        ? ShimmerLoadingWidget(
                                            height: 20,
                                            width: 24,
                                          )
                                        : Text(widget.taskCount.toString()),
                                    Text('Tasks'),
                                  ],
                                )),
                      SizedBox(width: 16),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: Text(_user?.name ?? 'Profile'),
                                  ),
                                  body: UserDetailsWidget(user: _user!),
                                ),
                              ),
                            );
                          },
                          child: widget.isInitialLoading
                              ? Column(
                                  children: [
                                    ShimmerLoadingWidget(
                                      height: 14,
                                      width: 22,
                                    ),
                                    ShimmerLoadingWidget(
                                      height: 14,
                                      width: 44,
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    widget.isLoading
                                        ? ShimmerLoadingWidget(
                                            height: 20,
                                            width: 24,
                                          )
                                        : Text(
                                            _user?.followersCount.toString() ??
                                                '0'),
                                    Text('Followers'),
                                  ],
                                )),
                      SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text(_user?.name ?? 'Profile'),
                                ),
                                body: UserDetailsWidget(
                                  user: _user!,
                                  initialTab: 1,
                                ),
                              ),
                            ),
                          );
                        },
                        child: widget.isInitialLoading
                            ? Column(
                                children: [
                                  ShimmerLoadingWidget(
                                    height: 14,
                                    width: 22,
                                  ),
                                  ShimmerLoadingWidget(
                                    height: 14,
                                    width: 44,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  widget.isLoading
                                      ? ShimmerLoadingWidget(
                                          height: 20,
                                          width: 24,
                                        )
                                      : Text(_user?.followingCount.toString() ??
                                          '0'),
                                  Text('Following'),
                                ],
                              ),
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
              if (_user?.id == AuthService().getLoggedInUser()?.id)
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          user: _user,
                          onUserUpdated: (User updatedUser) {
                            setState(() {
                              _user = updatedUser;
                            });
                          },
                        ),
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

  Future<void> _loadUser() async {
    final user = await UserService().getUser();
    setState(() {
      _user = user;
    });
  }
}
