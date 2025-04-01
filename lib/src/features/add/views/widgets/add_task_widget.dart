import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddTaskWidget extends StatefulWidget {
  const AddTaskWidget({
    super.key,
  });

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateInputController = TextEditingController();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _timeFormat = DateFormat('hh:mm a');
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  DateTime? _suggestedDate;
  int _priority = 4; // 4 is lowest priority, 1 is highest
  OverlayEntry? _overlayEntry;
  final FocusNode _dateInputFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  bool _isLoading = false; // Add this line to track loading state

  @override
  void initState() {
    super.initState();
    _dateInputFocusNode.addListener(_onFocusChange);
    dotenv.load();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _dateInputController.dispose();
    _dateInputFocusNode.removeListener(_onFocusChange);
    _dateInputFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_dateInputFocusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void manualDatePicker(BuildContext context) {
    _removeOverlay();

    if (_suggestedDate != null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 4),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDatePreview(_suggestedDate!),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDatePickerState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CompositedTransformTarget(
                          link: _layerLink,
                          child: TextField(
                            controller: _dateInputController,
                            focusNode: _dateInputFocusNode,
                            onChanged: (value) {
                              setDatePickerState(() {
                                try {
                                  final date = _dateFormat.parse(value);
                                  _suggestedDate = date;
                                  if (_dateInputFocusNode.hasFocus) {
                                    manualDatePicker(context);
                                  }
                                } catch (e) {
                                  _suggestedDate = null;
                                  _removeOverlay();
                                }
                              });
                            },
                            onTap: () => _dateInputFocusNode.hasFocus
                                ? manualDatePicker(context)
                                : defaultDatePicker(
                                    context: context,
                                    onDateSelected: (date) {
                                      setDatePickerState(() {
                                        _dueDate = date;
                                        _dateInputController.text =
                                            _dateFormat.format(date);
                                      });
                                    }),
                            decoration: InputDecoration(
                              hintText: 'Input a date (YYYY-MM-DD)',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              isDense: false,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  defaultDatePicker(
                      context: context,
                      onDateSelected: (date) {
                        setDatePickerState(() {
                          _dueDate = date;
                          _dateInputController.text = _dateFormat.format(date);
                        });

                        setState(() {
                          _dueDate = date;
                        });
                      }),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        _showTimePicker(context, onTimeSelected: (newTime) {
                          // Update both states when time is selected
                          setDatePickerState(() {
                            _dueTime = newTime;
                          });
                          setState(() {
                            _dueTime = newTime;
                            if (_dueDate != null && newTime != null) {
                              _dueDate = DateTime(
                                _dueDate!.year,
                                _dueDate!.month,
                                _dueDate!.day,
                                newTime.hour,
                                newTime.minute,
                              );
                            }
                          });
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _dueTime != null
                                ? _timeFormat.format(DateTime(2024, 1, 1,
                                    _dueTime!.hour, _dueTime!.minute))
                                : '時間',
                            style: TextStyle(
                              color: _dueTime != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTimePicker(BuildContext context,
      {Function(TimeOfDay?)? onTimeSelected}) {
    showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    ).then((TimeOfDay? newTime) {
      if (newTime != null) {
        setState(() {
          _dueTime = newTime;
          if (_dueDate != null) {
            _dueDate = DateTime(
              _dueDate!.year,
              _dueDate!.month,
              _dueDate!.day,
              newTime.hour,
              newTime.minute,
            );
          }
        });
        if (onTimeSelected != null) {
          onTimeSelected(newTime);
        }
      }
    });
  }

  Widget defaultDatePicker({
    required BuildContext context,
    required Function(DateTime) onDateSelected,
  }) {
    final now = DateTime.now();
    final firstDate = DateTime(2024);
    final initialDate = (_dueDate != null && _dueDate!.isAfter(firstDate))
        ? _dueDate!
        : (now.isAfter(firstDate) ? now : firstDate);

    return Container(
      height: 400,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              _buildQuickOption(
                icon: Icons.today,
                label: '今天',
                date: now,
                color: Colors.green,
                onDateSelected: onDateSelected,
              ),
              _buildQuickOption(
                icon: Icons.wb_sunny_outlined,
                label: '明天',
                date: now.add(const Duration(days: 1)),
                color: Colors.orange,
                onDateSelected: onDateSelected,
              ),
              _buildQuickOption(
                icon: Icons.calendar_today_outlined,
                label: '本週週末',
                date: now.add(Duration(
                  days: (DateTime.saturday - now.weekday + 7) % 7,
                )),
                color: Colors.purple,
                onDateSelected: onDateSelected,
              ),
              _buildQuickOption(
                icon: Icons.calendar_month,
                label: '下週',
                date: now.add(const Duration(days: 7)),
                color: Colors.indigo,
                onDateSelected: onDateSelected,
              ),
              const SizedBox(height: 4),
              Text(
                '${initialDate.year}年 ${initialDate.month}月',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: initialDate,
                    firstDate: firstDate,
                    lastDate: DateTime(2100),
                    onDateChanged: (DateTime value) {
                      setState(() {
                        _dueDate = value;
                        _dateInputController.text = _dateFormat.format(value);
                      });
                      onDateSelected(value);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickOption({
    required IconData icon,
    required String label,
    required DateTime date,
    required Color color,
    bool showDate = true,
    required Function(DateTime) onDateSelected,
  }) {
    final weekday = _getWeekdayInChinese(date.weekday);
    return InkWell(
      onTap: () {
        setState(() {
          if (showDate) {
            _dueDate = date;
            _dateInputController.text = _dateFormat.format(date);
            onDateSelected(date);
          } else {
            _dueDate = null;
            _dateInputController.clear();
          }
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            if (showDate)
              Text(
                weekday,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePreview(DateTime date) {
    final dateString = _dateFormat.format(date);
    final weekday = _getWeekdayInChinese(date.weekday);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            title: Text(
              '$dateString  $weekday',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: TextButton(
              onPressed: () {
                setState(() {
                  _dueDate = date;
                  _dateInputController.text = dateString;
                });
                _removeOverlay();
              },
              child: const Text('選擇'),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekdayInChinese(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '週${weekdays[weekday - 1]}';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement task creation logic
      // Close the AddTaskWidget after successful submission
      Navigator.of(context).pop(); // This will close the widget

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task Created')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isLoading // Show loading indicator if loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _taskController,
                      decoration: InputDecoration(
                          hintText: 'Enter task name',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16.0)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter description',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 4),
                    ListTile(
                      title: const Text('Due Date'),
                      subtitle: Text(
                        _dueDate == null
                            ? 'Not Set'
                            : '${_dateFormat.format(_dueDate!)} ${_getWeekdayInChinese(_dueDate!.weekday)}' +
                                (_dueTime != null
                                    ? ' ${_timeFormat.format(DateTime(2024, 1, 1, _dueTime!.hour, _dueTime!.minute))}'
                                    : ''),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _showDatePicker(context),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Priority',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(4, (index) {
                              final priority = index + 1;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _priority = priority),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _priority == priority
                                          ? _getPriorityColor(priority)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'P$priority',
                                        style: TextStyle(
                                          color: _priority == priority
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width:
                              80, // Set a specific width for the first button
                          child: ElevatedButton(
                            onPressed: () => _showAIPopup(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              backgroundColor: Colors.white,
                            ),
                            child: const Image(
                              image: AssetImage("assets/gemini_ai_icon.png"),
                              height: 23,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // Add spacing between buttons
                        SizedBox(
                          width:
                              80, // Set a specific width for the second button
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              backgroundColor: Colors.grey,
                            ),
                            child: const Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Color _getPriorityColor(int priority) {
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
        return Colors.grey;
    }
  }

  void _showAIPopup(BuildContext context) {
    final TextEditingController aiInputController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AI Task Suggestion'),
          content: TextField(
            controller: aiInputController,
            decoration: const InputDecoration(hintText: 'Enter your goal...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchAIDetails(aiInputController.text);
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchAIDetails(String goal) async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      final API_KEY = dotenv.env['DIFY_API_KEY'];

      final response = await http.post(
        Uri.parse('https://api.dify.ai/v1/chat-messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY'
        },
        body: json.encode({
          'query': goal,
          'user': 1,
          'inputs': {'goal': goal}
        }),
      );

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final answer = data['answer']; // Extract the answer field

        // Clean the answer string to remove code block formatting
        final cleanedAnswer =
            answer.replaceAll(RegExp(r'```json|```'), '').trim();

        // Parse the cleaned answer JSON string
        final answerData = json.decode(cleanedAnswer);

        setState(() {
          _taskController.text = answerData['task_name'] ?? '';
          _descriptionController.text = answerData['description'] ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI suggestions fetched successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch AI suggestions')),
        );
      }
    } catch (e) {
      print('Error: $e'); // Debug print for any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false after the API call
      });
    }
  }
}
