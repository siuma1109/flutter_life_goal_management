import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final double progress;
  final bool isCompleted;
  final VoidCallback onCompleted;

  const TaskCard({
    required this.title,
    required this.progress,
    required this.isCompleted,
    required this.onCompleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Checkbox(
                  value: isCompleted,
                  onChanged: (_) => onCompleted(),
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
