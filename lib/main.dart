import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}
