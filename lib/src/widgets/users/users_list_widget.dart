import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/broadcasts/user_broadcast.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/user_service.dart';
import 'package:flutter_life_goal_management/src/widgets/explore/users_shimmer_loading_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/users/user_list_item_widget.dart';

class UsersListWidget extends StatefulWidget {
  final String? search;
  const UsersListWidget({
    super.key,
    this.search,
  });

  @override
  _UsersListWidgetState createState() => _UsersListWidgetState();
}

class _UsersListWidgetState extends State<UsersListWidget> {
  List<User> _users = <User>[];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isInitialLoading = true;
  final ScrollController _scrollController = ScrollController();
  String _search = '';
  StreamSubscription? _userChangedSubscription;

  @override
  void initState() {
    super.initState();
    _search = widget.search ?? '';
    _getUsers();

    // Add scroll listener for infinite scrolling
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMoreData) {
        _getUsers();
      }
    });

    _userChangedSubscription = UserBroadcast().userChangedStream.listen((user) {
      setState(() {
        if (user != null) {
          final index = _users.indexWhere((element) => element.id == user.id);
          if (index != -1) {
            setState(() {
              _users[index] = user;
            });
          }
        }
      });
    });
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
      child: _isInitialLoading
          ? const UsersShimmerLoadingWidget()
          : _users.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    return UserListItemWidget(
                        key: Key(_users[index].id.toString()),
                        user: _users[index],
                        seeingUser: AuthService().getLoggedInUser()!);
                  },
                ),
    );
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _page = 1;
      _users.clear();
      _hasMoreData = true;
      _isInitialLoading = true;
    });
    await _getUsers();
  }

  Future<void> _getUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      print('Searching for: $_search');
      final users = await UserService().getUsers(
        page: _page,
        search: _search,
      );
      print('Users: $users');
      setState(() {
        if (users.isEmpty) {
          _hasMoreData = false;
        } else {
          _users.addAll(users);
          _page++;
        }
        _isLoading = false;
        _isInitialLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
        _isInitialLoading = false;
      });
    }
  }
}
