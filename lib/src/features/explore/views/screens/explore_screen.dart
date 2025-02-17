import 'package:flutter/material.dart';

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
    );
  }
}
