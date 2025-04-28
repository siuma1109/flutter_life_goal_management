import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/user_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/user_service.dart';
import 'package:flutter_life_goal_management/src/widgets/users/user_list_item_widget.dart';

class UserFollowersListWidget extends StatefulWidget {
  final User user;
  final String? search;
  const UserFollowersListWidget({
    super.key,
    required this.user,
    this.search,
  });

  @override
  UserFollowersListWidgetState createState() => UserFollowersListWidgetState();
}

class UserFollowersListWidgetState extends State<UserFollowersListWidget> {
  List<User> _users = <User>[];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  String _search = '';
  StreamSubscription? _userChangedSubscription;

  @override
  void initState() {
    super.initState();
    _search = widget.search ?? '';
    _getUserFollowers();

    // Add scroll listener for infinite scrolling
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMoreData) {
        _getUserFollowers();
      }
    });

    _userChangedSubscription = UserBroadcast().userChangedStream.listen((_) {
      _refreshUsers();
    });
  }

  void refreshWithSearch(String search) {
    setState(() {
      _search = search;
      print('Search: $_search');
      _page = 1;
      _users.clear();
      _hasMoreData = true;
    });
    _getUserFollowers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _userChangedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: _users.isEmpty
          ? const Center(child: Text('No users found'))
          : ListView.builder(
              controller: _scrollController,
              itemCount: _users.length,
              itemBuilder: (context, index) {
                return UserListItemWidget(user: _users[index]);
              },
            ),
    );
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _page = 1;
      _users.clear();
      _hasMoreData = true;
    });
    await _getUserFollowers();
  }

  Future<void> _getUserFollowers() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      print('Searching for: $_search');
      final users = await UserService().getUserFollowers(
        user: widget.user,
        page: _page,
        search: _search,
      );
      print('Users: $users');
      if (users.isNotEmpty) {
        setState(() {
          if (users.isEmpty) {
            _hasMoreData = false;
          } else {
            _users.addAll(users);
            _page++;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
}
