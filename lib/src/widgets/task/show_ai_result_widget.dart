import 'package:flutter/material.dart';

class ShowAIResultWidget extends StatefulWidget {
  final Map<String, dynamic> aiResult;
  final Function(String taskName, String description,
      List<Map<String, dynamic>> subTasks) onAccept;

  const ShowAIResultWidget({
    super.key,
    required this.aiResult,
    required this.onAccept,
  });

  @override
  State<ShowAIResultWidget> createState() => _ShowAIResultWidgetState();
}

class _ShowAIResultWidgetState extends State<ShowAIResultWidget> {
  String _taskName = '';
  String _description = '';
  List<Map<String, dynamic>> _subTasks = [];

  @override
  void initState() {
    super.initState();
    _taskName = widget.aiResult['task_name'] ?? '';
    _description = widget.aiResult['description'] ?? '';

    // Parse subTasks from the AI result
    _subTasks = [];
    if (widget.aiResult['sub_tasks'] != null) {
      if (widget.aiResult['sub_tasks'] is List) {
        _subTasks =
            List<Map<String, dynamic>>.from(widget.aiResult['sub_tasks']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Suggestion',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Task Name:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_taskName),
            SizedBox(height: 16),
            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_description),
            if (_subTasks.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'SubTasks:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FlexColumnWidth(0.1), // Adjust width for the index column
                  1: FlexColumnWidth(0.4), // Adjust width for the title column
                  2: FlexColumnWidth(
                      0.5), // Adjust width for the description column
                },
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No.',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Title',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Description',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...List.generate(
                    _subTasks.length,
                    (index) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${index + 1}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_subTasks[index]['task_name'] ?? ''),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_subTasks[index]['description'] ?? ''),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16),
            Divider(),
            Padding(
              padding: EdgeInsets.only(left: 18, right: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 4),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: const Icon(Icons.cancel_outlined, size: 24)),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onAccept(_taskName, _description, _subTasks);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 4),
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
