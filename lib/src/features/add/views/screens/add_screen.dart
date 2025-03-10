import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddScreen extends StatefulWidget {
  final String title;

  const AddScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
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

  // Dummy data for tasks
  final Map<String, List<String>> _dummyTasks = {
    '2024-03-15': ['週末大掃除', '準備下週報告', '買菜'],
    '2024-03-16': ['看電影', '購物', '健身'],
    '2024-03-17': ['週會準備', '整理衣櫃', '洗車'],
    '2024-03-18': ['提交報告', '下午茶約會'],
    '2024-03-19': ['牙醫預約', '修電腦'],
  };

  @override
  void initState() {
    super.initState();
    _dateInputFocusNode.addListener(_onFocusChange);
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

  void _showOverlay(BuildContext context) {
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
            child: _buildDatePreview(_suggestedDate!),
          ),
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _showDatePicker(BuildContext context) {
    _removeOverlay(); // Remove any existing overlay when showing date picker
    final now = DateTime.now();
    final firstDate = DateTime(2024);
    // Ensure initialDate is not before firstDate
    final initialDate = (_dueDate != null && _dueDate!.isAfter(firstDate))
        ? _dueDate!
        : (now.isAfter(firstDate) ? now : firstDate);

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
                                    _showOverlay(context);
                                  }
                                } catch (e) {
                                  _suggestedDate = null;
                                  _removeOverlay();
                                }
                              });
                            },
                            onTap: () => _showOverlay(context),
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
                  const SizedBox(height: 16),
                  _buildQuickOption(
                    icon: Icons.today,
                    label: '今天',
                    date: now,
                    color: Colors.green,
                  ),
                  _buildQuickOption(
                    icon: Icons.wb_sunny_outlined,
                    label: '明天',
                    date: now.add(const Duration(days: 1)),
                    color: Colors.orange,
                  ),
                  _buildQuickOption(
                    icon: Icons.calendar_today_outlined,
                    label: '本週週末',
                    date: now.add(Duration(
                      days: (DateTime.saturday - now.weekday + 7) % 7,
                    )),
                    color: Colors.purple,
                  ),
                  _buildQuickOption(
                    icon: Icons.calendar_month,
                    label: '下週',
                    date: now.add(const Duration(days: 7)),
                    color: Colors.indigo,
                  ),
                  _buildQuickOption(
                    icon: Icons.calendar_today_outlined,
                    label: '沒有日期',
                    date: now,
                    color: Colors.grey,
                    showDate: false,
                  ),
                  const SizedBox(height: 16),
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
                          setDatePickerState(() {
                            _dueDate = value;
                            _dateInputController.text =
                                _dateFormat.format(value);
                            if (_dueTime != null) {
                              _dueDate = DateTime(
                                value.year,
                                value.month,
                                value.day,
                                _dueTime!.hour,
                                _dueTime!.minute,
                              );
                            }
                          });
                          setState(() {
                            _dueDate = value;
                            if (_dueTime != null) {
                              _dueDate = DateTime(
                                value.year,
                                value.month,
                                value.day,
                                _dueTime!.hour,
                                _dueTime!.minute,
                              );
                            }
                          });
                        },
                      ),
                    ),
                  ),
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
    // Create a local copy of the current time
    TimeOfDay? localTime = _dueTime != null
        ? TimeOfDay(hour: _dueTime!.hour, minute: _dueTime!.minute)
        : null;

    final timeController = TextEditingController(
      text: localTime != null
          ? _timeFormat
              .format(DateTime(2024, 1, 1, localTime.hour, localTime.minute))
          : '',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void updateLocalTime(TimeOfDay? newTime) {
              setDialogState(() {
                localTime = newTime;
                if (newTime != null) {
                  timeController.text = _timeFormat.format(
                      DateTime(2024, 1, 1, newTime.hour, newTime.minute));
                }
              });
            }

            void saveTime() {
              // Update parent state
              setState(() {
                _dueTime = localTime;
                if (_dueDate != null && localTime != null) {
                  _dueDate = DateTime(
                    _dueDate!.year,
                    _dueDate!.month,
                    _dueDate!.day,
                    localTime!.hour,
                    localTime!.minute,
                  );
                }
              });

              // Notify date picker about time change
              if (onTimeSelected != null) {
                onTimeSelected(localTime);
              }

              // Close time picker dialog
              Navigator.pop(dialogContext);
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '時間',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: timeController,
                            decoration: const InputDecoration(
                              hintText: 'Enter time (e.g., 9:00 AM)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              try {
                                TimeOfDay? parsedTime;

                                // Try to parse time in various formats
                                if (value.toLowerCase().contains('am') ||
                                    value.toLowerCase().contains('pm')) {
                                  // Parse AM/PM format
                                  final parts = value.toLowerCase().split(' ');
                                  if (parts.length == 2) {
                                    final timeParts = parts[0].split(':');
                                    if (timeParts.length == 2) {
                                      var hour =
                                          int.tryParse(timeParts[0]) ?? 0;
                                      final minute =
                                          int.tryParse(timeParts[1]) ?? 0;
                                      final isAM = parts[1].contains('am');

                                      if (hour == 12) {
                                        hour = isAM ? 0 : 12;
                                      } else if (!isAM) {
                                        hour += 12;
                                      }

                                      if (hour >= 0 &&
                                          hour < 24 &&
                                          minute >= 0 &&
                                          minute < 60) {
                                        parsedTime = TimeOfDay(
                                            hour: hour, minute: minute);
                                      }
                                    }
                                  }
                                } else if (value.contains(':')) {
                                  // Parse 24-hour format
                                  final parts = value.split(':');
                                  if (parts.length == 2) {
                                    final hour = int.tryParse(parts[0]) ?? 0;
                                    final minute = int.tryParse(parts[1]) ?? 0;

                                    if (hour >= 0 &&
                                        hour < 24 &&
                                        minute >= 0 &&
                                        minute < 60) {
                                      parsedTime =
                                          TimeOfDay(hour: hour, minute: minute);
                                    }
                                  }
                                }

                                if (parsedTime != null) {
                                  updateLocalTime(parsedTime);
                                }

                                // Generate and show suggestions
                                final suggestions =
                                    _generateTimeSuggestions(value);
                                if (suggestions.isNotEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        contentPadding: EdgeInsets.zero,
                                        content: Container(
                                          width: double.maxFinite,
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                          ),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: suggestions.length,
                                            itemBuilder: (context, index) {
                                              final suggestion =
                                                  suggestions[index];
                                              return ListTile(
                                                dense: true,
                                                title: Text(suggestion),
                                                onTap: () {
                                                  // Parse the suggestion time
                                                  final parts = suggestion
                                                      .toLowerCase()
                                                      .split(' ');
                                                  if (parts.length == 2) {
                                                    final timeParts =
                                                        parts[0].split(':');
                                                    if (timeParts.length == 2) {
                                                      var hour = int.tryParse(
                                                              timeParts[0]) ??
                                                          0;
                                                      final minute =
                                                          int.tryParse(
                                                                  timeParts[
                                                                      1]) ??
                                                              0;
                                                      final isAM = parts[1]
                                                          .contains('am');

                                                      if (hour == 12) {
                                                        hour = isAM ? 0 : 12;
                                                      } else if (!isAM) {
                                                        hour += 12;
                                                      }

                                                      if (hour >= 0 &&
                                                          hour < 24 &&
                                                          minute >= 0 &&
                                                          minute < 60) {
                                                        final newTime =
                                                            TimeOfDay(
                                                                hour: hour,
                                                                minute: minute);
                                                        updateLocalTime(
                                                            newTime);
                                                      }
                                                    }
                                                  }
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              } catch (e) {
                                // Invalid time format
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTimeOption(
                            icon: Icons.access_time,
                            label: '上午',
                            time: const TimeOfDay(hour: 9, minute: 0),
                            onTimeSelected: updateLocalTime,
                            selectedTime: localTime,
                          ),
                          _buildTimeOption(
                            icon: Icons.access_time,
                            label: '下午',
                            time: const TimeOfDay(hour: 14, minute: 0),
                            onTimeSelected: updateLocalTime,
                            selectedTime: localTime,
                          ),
                          _buildTimeOption(
                            icon: Icons.access_time,
                            label: '晚上',
                            time: const TimeOfDay(hour: 20, minute: 0),
                            onTimeSelected: updateLocalTime,
                            selectedTime: localTime,
                          ),
                          const Divider(),
                          _buildTimeOption(
                            icon: Icons.timer_outlined,
                            label: '沒有時間',
                            showTime: false,
                            onTimeSelected: updateLocalTime,
                            selectedTime: localTime,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('時區'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('浮動時區'),
                              const Spacer(),
                              Icon(Icons.keyboard_arrow_down,
                                  color: Colors.grey[600]),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: saveTime,
                          child: const Text('保存'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickOption({
    required IconData icon,
    required String label,
    required DateTime date,
    required Color color,
    bool showDate = true,
  }) {
    final weekday = _getWeekdayInChinese(date.weekday);
    return InkWell(
      onTap: () {
        setState(() {
          if (showDate) {
            _dueDate = date;
            _dateInputController.text = _dateFormat.format(date);
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
    final tasks = _dummyTasks[dateString] ?? [];

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
          if (tasks.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '當天任務：',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...tasks.map((task) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.task_alt,
                                size: 16, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeOption({
    required IconData icon,
    required String label,
    TimeOfDay? time,
    bool showTime = true,
    required Function(TimeOfDay?) onTimeSelected,
    TimeOfDay? selectedTime,
  }) {
    return InkWell(
      onTap: () => onTimeSelected(time),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            if (showTime) ...[
              const Spacer(),
              Icon(
                Icons.check,
                color: selectedTime?.hour == time?.hour &&
                        selectedTime?.minute == time?.minute
                    ? Colors.orange[700]
                    : Colors.transparent,
                size: 20,
              ),
            ],
          ],
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task Created')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
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
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Priority', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(4, (index) {
                          final priority = index + 1;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _priority = priority),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
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
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child:
                    const Text('Create Task', style: TextStyle(fontSize: 16)),
              ),
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

  List<String> _generateTimeSuggestions(String input) {
    if (input.isEmpty) return [];

    final suggestions = <String>[];
    final now = DateTime.now();

    // Common time patterns with AM/PM
    final commonTimes = [
      TimeOfDay(hour: 9, minute: 0), // 9:00 AM
      TimeOfDay(hour: 10, minute: 0), // 10:00 AM
      TimeOfDay(hour: 11, minute: 0), // 11:00 AM
      TimeOfDay(hour: 12, minute: 0), // 12:00 PM
      TimeOfDay(hour: 13, minute: 0), // 1:00 PM
      TimeOfDay(hour: 14, minute: 0), // 2:00 PM
      TimeOfDay(hour: 15, minute: 0), // 3:00 PM
      TimeOfDay(hour: 16, minute: 0), // 4:00 PM
      TimeOfDay(hour: 17, minute: 0), // 5:00 PM
      TimeOfDay(hour: 18, minute: 0), // 6:00 PM
      TimeOfDay(hour: 19, minute: 0), // 7:00 PM
      TimeOfDay(hour: 20, minute: 0), // 8:00 PM
    ];

    final inputLower = input.toLowerCase();

    // Filter suggestions based on input
    for (var time in commonTimes) {
      final timeString = _timeFormat.format(
          DateTime(now.year, now.month, now.day, time.hour, time.minute));
      if (timeString.toLowerCase().contains(inputLower)) {
        suggestions.add(timeString);
      }
    }

    // Add minute variations if hour is entered
    if (input.length >= 1) {
      try {
        var hour = int.parse(input.split(':')[0]);
        if (hour > 0 && hour <= 12) {
          // Add both AM and PM variations
          for (var minute in [0, 15, 30, 45]) {
            // AM
            final amTime = DateTime(now.year, now.month, now.day, hour, minute);
            suggestions.add(_timeFormat.format(amTime));

            // PM
            final pmTime =
                DateTime(now.year, now.month, now.day, hour + 12, minute);
            suggestions.add(_timeFormat.format(pmTime));
          }
        }
      } catch (e) {
        // Invalid hour format
      }
    }

    return suggestions..sort();
  }
}
