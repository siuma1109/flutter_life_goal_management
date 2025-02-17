import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String title;

  const ProfileScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Profile Screen Content'),
      ),
    );
  }
}
