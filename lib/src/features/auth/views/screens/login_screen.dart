import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final String title;

  const LoginScreen({super.key, required this.title});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Login Page',
            ),
          ],
        ),
      ),
    );
  }
}
