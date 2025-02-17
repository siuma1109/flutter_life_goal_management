import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  final String title;

  const CommunityScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Community Screen Content'),
      ),
    );
  }
}
