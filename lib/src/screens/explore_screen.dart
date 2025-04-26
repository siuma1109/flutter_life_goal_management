import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/screens/search_screen.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';
import 'package:flutter_life_goal_management/src/widgets/users/users_list_widget.dart';

class ExploreScreen extends StatefulWidget {
  final String title;

  const ExploreScreen({
    super.key,
    required this.title,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(),
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
                  'Search',
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
      body: UsersListWidget(),
      floatingActionButton: AddTaskFloatingButtonWidget(),
    );
  }
}
