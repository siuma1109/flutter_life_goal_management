import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/user_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/user_service.dart';
import 'package:flutter_life_goal_management/src/widgets/explore/users_shimmer_loading_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/users/user_list_item_widget.dart';

class UserFollowingListWidget extends StatefulWidget {
  final User user;
  final String? search;
  const UserFollowingListWidget({
    super.key,
    required this.user,
    this.search,
  });

  @override
  UserFollowingListWidgetState createState() => UserFollowingListWidgetState();
}

class UserFollowingListWidgetState extends State<UserFollowingListWidget> {
  List<User> _users = <User>[];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();
  String _search = '';
  StreamSubscription? _userChangedSubscription;
  bool _isInitialLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

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
      //_refreshUsers();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
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
      key: _refreshIndicatorKey,
      onRefresh: _refreshUsers,
      child: _isInitialLoading
          ? UsersShimmerLoadingWidget()
          : _users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    return UserListItemWidget(
                      key: Key(_users[index].id.toString()),
                      user: _users[index],
                      seeingUser: widget.user,
                    );
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
    setState(() {
      _isLoading = true;
    });
    try {
      print('Searching for: $_search');
      final users = await UserService().getUserFollowing(
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
            print('Users Len: ${_users.length}');
            print('Page: $_page');
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
    setState(() {
      _isInitialLoading = false;
    });
  }
}
