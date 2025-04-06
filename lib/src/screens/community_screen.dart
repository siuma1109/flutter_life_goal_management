import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';

class CommunityScreen extends StatelessWidget {
  final String title;

  const CommunityScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Community Screen Content'),
      ),
      floatingActionButton: AddTaskFloatingButtonWidget(),
    );
  }
}
