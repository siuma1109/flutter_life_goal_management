import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/widgets/task/add_task_floating_button_widget.dart';

class ExploreScreen extends StatelessWidget {
  final String title;

  const ExploreScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Explore Screen Content'),
      ),
      floatingActionButton: AddTaskFloatingButtonWidget(),
    );
  }
}
