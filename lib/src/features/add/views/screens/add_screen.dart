import 'package:flutter/material.dart';

class AddScreen extends StatelessWidget {
  final String title;

  const AddScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Add Screen Content'),
      ),
    );
  }
}
