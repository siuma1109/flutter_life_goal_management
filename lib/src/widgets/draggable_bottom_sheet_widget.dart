import 'package:flutter/material.dart';

class DraggableBottomSheetWidget extends StatefulWidget {
  final Widget child;
  final double minHeightFactor;
  final double maxHeightFactor;

  const DraggableBottomSheetWidget({
    super.key,
    required this.child,
    this.minHeightFactor = 0.5,
    this.maxHeightFactor = 0.9,
  });

  @override
  State<DraggableBottomSheetWidget> createState() =>
      _DraggableBottomSheetWidgetState();
}

class _DraggableBottomSheetWidgetState extends State<DraggableBottomSheetWidget>
    with WidgetsBindingObserver {
  late double _currentHeightFactor;
  late double _minHeightFactor;
  late double _maxHeightFactor;
  bool _isAnimating = false; // To prevent multiple animations
  bool isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    _minHeightFactor = widget.minHeightFactor;
    _maxHeightFactor = widget.maxHeightFactor;
    _currentHeightFactor = widget.minHeightFactor;

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkKeyboardStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _checkKeyboardStatus();
  }

  void _checkKeyboardStatus() {
    final newKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if (newKeyboardOpen != isKeyboardOpen) {
      setState(() {
        isKeyboardOpen = newKeyboardOpen;
      });
    }
    if (isKeyboardOpen) {
      setState(() {
        _currentHeightFactor = _maxHeightFactor;
      });
    } else {
      setState(() {
        _currentHeightFactor = _minHeightFactor;
      });
    }
  }

  void _expandBottomSheet(DragUpdateDetails details) {
    if (_isAnimating) return;

    setState(() {
      _currentHeightFactor = (_currentHeightFactor -
              details.delta.dy / MediaQuery.of(context).size.height)
          .clamp(_minHeightFactor, _maxHeightFactor);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
    });

    double snapToHeightFactor;
    if (_currentHeightFactor > (_minHeightFactor + _maxHeightFactor) / 2) {
      snapToHeightFactor = _maxHeightFactor;
    } else {
      snapToHeightFactor = _minHeightFactor;
    }

    setState(() {
      _currentHeightFactor = snapToHeightFactor;
    });

    // Animate to the target height
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _isAnimating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _currentHeightFactor,
      minChildSize: _minHeightFactor,
      maxChildSize: _maxHeightFactor,
      expand: false,
      builder: (context, scrollController) {
        return GestureDetector(
          onVerticalDragUpdate: _expandBottomSheet,
          onVerticalDragEnd: _onDragEnd,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 6,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
      },
    );
  }
}
