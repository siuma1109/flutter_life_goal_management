import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Add this method to check if user is logged in
  bool isUserLoggedIn() {
    // TODO: Implement actual auth check
    return false; // Temporary return false
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(
          isUserLoggedIn() ? 'Welcome back!' : 'Welcome Guest!',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}
