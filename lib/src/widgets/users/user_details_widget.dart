import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/models/user.dart';
import 'package:flutter_life_goal_management/src/widgets/users/user_followers_list_item_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/users/user_following_list_item_widget.dart';

class UserDetailsWidget extends StatefulWidget {
  final User user;
  final int? initialTab;

  const UserDetailsWidget({
    super.key,
    required this.user,
    this.initialTab,
  });

  @override
  State<UserDetailsWidget> createState() => _UserDetailsWidgetState();
}

class _UserDetailsWidgetState extends State<UserDetailsWidget>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<UserFollowersListWidgetState> _followersListKey =
      GlobalKey<UserFollowersListWidgetState>();
  final GlobalKey<UserFollowingListWidgetState> _followingListKey =
      GlobalKey<UserFollowingListWidgetState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialTab != null) {
      _tabController.animateTo(widget.initialTab!);
    }
  }

  @override
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: UserFollowersListWidget(
                          key: _followersListKey,
                          user: widget.user,
                          search: _search),
                    ),
                  ],
                ),
                Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: UserFollowingListWidget(
                          key: _followingListKey,
                          user: widget.user,
                          search: _search),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Container(
          height: 36,
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            //focusNode: focusNode,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 18),
              hintText: 'Search',
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            onSubmitted: (value) {
              _formKey.currentState?.validate();
              setState(() {
                _search = value;
              });
              _followersListKey.currentState?.refreshWithSearch(value);
              _followingListKey.currentState?.refreshWithSearch(value);
            },
          ),
        ),
      ),
    );
  }
}
