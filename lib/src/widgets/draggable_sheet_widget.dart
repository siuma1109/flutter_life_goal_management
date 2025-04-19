import 'package:flutter/material.dart';

class DraggableSheetWidget extends StatefulWidget {
  final Widget child;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final bool expand;
  const DraggableSheetWidget({
    super.key,
    required this.child,
    this.initialChildSize = 0.5,
    this.minChildSize = 0,
    this.maxChildSize = 0.9,
    this.expand = false,
  });

  @override
  State<DraggableSheetWidget> createState() => _DraggableSheetWidgetState();
}

class _DraggableSheetWidgetState extends State<DraggableSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      expand: widget.expand,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: widget.child,
        );
      },
    );
  }
}
