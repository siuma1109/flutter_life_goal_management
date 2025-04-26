import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/projects/project_list_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/explore/explore_task_list_widget.dart';
import 'package:flutter_life_goal_management/src/screens/search_screen.dart';
import 'package:flutter_life_goal_management/src/widgets/users/users_list_widget.dart';

class SearchResultScreen extends StatefulWidget {
  final String search;
  const SearchResultScreen({super.key, required this.search});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchController.text = widget.search;
  }

  @override
  void dispose() {
    focusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  search: widget.search,
                ),
              ),
            );
          },
          child: Container(
            height: 36,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.search, color: Colors.grey[600], size: 18),
                ),
                Text(
                  widget.search,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 3,
        child: searchController.text.isEmpty
            ? SizedBox.shrink()
            : Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Users'),
                      Tab(text: 'Projects'),
                      Tab(text: 'Tasks'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        UsersListWidget(search: widget.search),
                        ProjectListWidget(search: widget.search),
                        ExploreTaskListWidget(search: widget.search),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
