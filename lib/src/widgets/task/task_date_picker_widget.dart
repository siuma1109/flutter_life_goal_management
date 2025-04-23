import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_life_goal_management/src/models/task.dart';

class TaskDatePickerWidget extends StatefulWidget {
  final Task task;
  final Function(DateTime?) onDateSelected;
  final Function(TimeOfDay?) onTimeSelected;

  const TaskDatePickerWidget({
    super.key,
    required this.task,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  State<TaskDatePickerWidget> createState() => _TaskDatePickerWidgetState();
}

class _TaskDatePickerWidgetState extends State<TaskDatePickerWidget> {
  final LayerLink _layerLink = LayerLink();
  final _dateInputController = TextEditingController();
  final _dateInputFocusNode = FocusNode();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _timeFormat = DateFormat('hh:mm a');
  DateTime? _startDate;
  TimeOfDay? _dueTime;
  DateTime? _suggestedDate;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _dateInputFocusNode.addListener(_onFocusChange);
    _startDate = widget.task.startDate;
    if (_startDate != null) {
      _dueTime = TimeOfDay(hour: _startDate!.hour, minute: _startDate!.minute);
      _dateInputController.text = _dateFormat.format(_startDate!);
    }
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 36),
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
                      setState(() {
                        try {
                          final date = _dateFormat.parse(value);
                          _suggestedDate = date;
                        } catch (e) {
                          _suggestedDate = null;
                          _removeOverlay();
                        }
                      });
                    },
                    onTap: () {
                      _dateInputFocusNode.requestFocus();
                    },
                    decoration: InputDecoration(
                        hintText: 'Input a date (YYYY-MM-DD)',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                        isDense: false,
                        border: InputBorder.none),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          defaultDatePicker(
              context: context,
              onDateSelected: (date) {
                setState(() {
                  _startDate = date;
                  _dateInputController.text =
                      date != null ? _dateFormat.format(date) : "";
                });
                widget.onDateSelected(date);
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
                  setState(() {
                    _dueTime = newTime;
                    if (_startDate != null && newTime != null) {
                      _startDate = DateTime(
                        _startDate!.year,
                        _startDate!.month,
                        _startDate!.day,
                        newTime.hour,
                        newTime.minute,
                      );
                    }
                  });
                  widget.onTimeSelected(newTime);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _dueTime != null
                        ? _timeFormat.format(DateTime(
                            2024, 1, 1, _dueTime!.hour, _dueTime!.minute))
                        : '時間',
                    style: TextStyle(
                      color: _dueTime != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                widget.onDateSelected(_startDate);
                Navigator.pop(context);
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
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
          if (_startDate != null) {
            _startDate = DateTime(
              _startDate!.year,
              _startDate!.month,
              _startDate!.day,
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
    required Function(DateTime?) onDateSelected,
  }) {
    final now = DateTime.now();
    final firstDate = DateTime(2024);
    final initialDate = (_startDate != null && _startDate!.isAfter(firstDate))
        ? _startDate!
        : (now.isAfter(firstDate) ? now : firstDate);

    return Container(
      height: 500,
      child: Column(
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
          _buildQuickOption(
            icon: Icons.calendar_month,
            label: '沒有日期',
            date: null,
            color: Colors.red,
            showDate: false,
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
                    _startDate = value;
                    _dateInputController.text = _dateFormat.format(value);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOption({
    required IconData icon,
    required String label,
    DateTime? date,
    required Color color,
    bool showDate = true,
    required Function(DateTime?) onDateSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          if (showDate && date != null) {
            _startDate = date;
            _dateInputController.text = _dateFormat.format(date);
            onDateSelected(date);
          } else {
            _startDate = null;
            _dueTime = null;
            _dateInputController.clear();
            onDateSelected(null);
            widget.onTimeSelected(null);
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
            if (showDate && date != null)
              Text(
                _getWeekdayInChinese(date.weekday),
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

  String _getWeekdayInChinese(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '週${weekdays[weekday - 1]}';
  }
}
