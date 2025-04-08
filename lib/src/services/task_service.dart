import 'package:flutter/material.dart';

class TaskService {
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
