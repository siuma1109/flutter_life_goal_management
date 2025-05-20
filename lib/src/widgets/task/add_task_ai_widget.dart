import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/services/task_service.dart';
//import 'package:flutter_life_goal_management/src/widgets/task/show_ai_result_widget.dart';

class AddTaskAIWidget extends StatefulWidget {
  final Function(
      String taskName,
      String description,
      int priority,
      String startDate,
      String endDate,
      List<Map<String, dynamic>> subTasks) onAccept;

  const AddTaskAIWidget({
    super.key,
    required this.onAccept,
  });

  @override
  State<AddTaskAIWidget> createState() => _AddTaskAIWidgetState();
}

class _AddTaskAIWidgetState extends State<AddTaskAIWidget> {
  final TextEditingController _goalPrompt = TextEditingController();
  final FocusNode _goalPromptFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Request focus on the goal prompt text field when the widget is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_goalPromptFocusNode);
    });
  }

  @override
  void dispose() {
    _goalPrompt.dispose();
    _goalPromptFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _goalPrompt,
                      focusNode: _goalPromptFocusNode,
                      decoration: const InputDecoration(
                          hintText: 'Enter your goal to get suggestions...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16.0)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a goal';
                        }
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _fetchAiResult();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              backgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Icon(
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
              ),
            ),
    );
  }

  Future<void> _fetchAiResult() async {
    setState(() {
      _isLoading = true;
    });

    try {
      //final result = await AIService().fetchAIDetails(_goalPrompt.text);
      final result = await TaskService().getAiSuggestions(_goalPrompt.text);

      // Close input dialog first
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result != null && mounted) {
        _showAiResult(context, result);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get AI suggestions')),
        );
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAiResult(BuildContext context, Map<String, dynamic> result) {
    final subTasks = List<Map<String, dynamic>>.from(result['sub_tasks']);
    widget.onAccept(
      result['task_name'],
      result['description'],
      result['priority'],
      result['start_date'],
      result['end_date'],
      subTasks,
    );
    // Navigator.of(context, rootNavigator: true).push(
    //   MaterialPageRoute(
    //     builder: (context) => ShowAIResultWidget(
    //       aiResult: result,
    //       onAccept: widget.onAccept,
    //     ),
    //   ),
    // );
  }
}
