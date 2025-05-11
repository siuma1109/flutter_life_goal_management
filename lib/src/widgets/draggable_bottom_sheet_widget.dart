import 'package:flutter/material.dart';

class DraggableBottomSheetWidget extends StatefulWidget {
  final Widget child;
  final double minHeightFactor;
  final double maxHeightFactor;
  final Function? onClose;

  const DraggableBottomSheetWidget({
    super.key,
    required this.child,
    this.minHeightFactor = 0.5,
    this.maxHeightFactor = 0.9,
    this.onClose,
  });

  @override
  State<DraggableBottomSheetWidget> createState() =>
      _DraggableBottomSheetWidgetState();
}

class _DraggableBottomSheetWidgetState extends State<DraggableBottomSheetWidget>
    with WidgetsBindingObserver {
  late DraggableScrollableController _dragController;
  ScrollController? _scrollController;
  bool _isKeyboardOpen = false;
  bool _isScrollingList = false;

  // Close threshold - below this percentage of min height will close the sheet
  static const double _closeThresholdPercent = 0.8;

  // Tracking overscroll for boundaries
  double _topOverscroll = 0;
  double _bottomOverscroll = 0;
  static const double _overscrollThreshold = 50.0;

  @override
  void initState() {
    super.initState();
    _dragController = DraggableScrollableController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _dragController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _checkKeyboardStatus();
  }

  void _checkKeyboardStatus() {
    final newKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (newKeyboardOpen != _isKeyboardOpen) {
      setState(() {
        _isKeyboardOpen = newKeyboardOpen;
      });

      if (_isKeyboardOpen) {
        _dragController.animateTo(
          widget.maxHeightFactor,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _resetOverscrollTracking() {
    _topOverscroll = 0;
    _bottomOverscroll = 0;
  }

  void _handleSheetClosing(double currentSize) {
    final closeThreshold = widget.minHeightFactor * _closeThresholdPercent;

    if (currentSize < closeThreshold) {
      // Close the sheet
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        Navigator.of(context).pop();
      }
    } else if (currentSize < widget.minHeightFactor) {
      // Snap back to min height
      _dragController.animateTo(
        widget.minHeightFactor,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        // Update state based on the sheet's position
        setState(() {});
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: widget.minHeightFactor,
        minChildSize:
            widget.minHeightFactor * 0.1, // Allow dragging below min height
        maxChildSize: widget.maxHeightFactor,
        controller: _dragController,
        expand: false,
        snap: true,
        snapSizes: [widget.minHeightFactor, widget.maxHeightFactor],
        builder: (context, scrollController) {
          _scrollController = scrollController;
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Reset tracking when scroll activity stops
              if (notification is ScrollEndNotification) {
                _isScrollingList = false;
                _resetOverscrollTracking();
                return false;
              }

              if (notification is ScrollStartNotification) {
                _isScrollingList = true;
                return false;
              }

              if (notification is ScrollUpdateNotification &&
                  _isScrollingList) {
                final double scrollDelta = notification.scrollDelta ?? 0;

                // Tracking overscroll at top
                if (notification.metrics.pixels <= 0) {
                  if (scrollDelta < 0) {
                    // trying to scroll down at the top
                    _topOverscroll += -scrollDelta;

                    // Only collapse after threshold is reached
                    if (_topOverscroll > _overscrollThreshold &&
                        _dragController.size > widget.minHeightFactor) {
                      _dragController.animateTo(
                        widget.minHeightFactor,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _resetOverscrollTracking();
                      return true;
                    }
                  } else {
                    _topOverscroll =
                        0; // Reset if scrolling in opposite direction
                  }
                }

                // Tracking overscroll at bottom
                if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent) {
                  if (scrollDelta > 0) {
                    // trying to scroll up at the bottom
                    _bottomOverscroll += scrollDelta;

                    // Only expand after threshold is reached
                    if (_bottomOverscroll > _overscrollThreshold &&
                        _dragController.size < widget.maxHeightFactor) {
                      _dragController.animateTo(
                        widget.maxHeightFactor,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _resetOverscrollTracking();
                      return true;
                    }
                  } else {
                    _bottomOverscroll =
                        0; // Reset if scrolling in opposite direction
                  }
                }
              }
              return false;
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      // Reset overscroll tracking when manually dragging
                      _resetOverscrollTracking();

                      // Calculate the new size based on drag
                      final newSize = _dragController.size -
                          (details.delta.dy /
                              MediaQuery.of(context).size.height);
                      if (newSize >= widget.minHeightFactor * 0.1 &&
                          newSize <= widget.maxHeightFactor) {
                        _dragController.jumpTo(newSize);
                      }
                    },
                    onVerticalDragEnd: (details) {
                      // Get current size to determine if we should close
                      final currentSize = _dragController.size;

                      // If below close threshold, close the sheet
                      if (currentSize < widget.minHeightFactor) {
                        _handleSheetClosing(currentSize);
                        return;
                      }

                      // Otherwise determine where to snap based on velocity and position
                      final velocity = details.primaryVelocity ?? 0;
                      final midPoint =
                          (widget.minHeightFactor + widget.maxHeightFactor) / 2;

                      double targetSize;
                      if (velocity < -500) {
                        // Strong upward swipe
                        targetSize = widget.maxHeightFactor;
                      } else if (velocity > 500) {
                        // Strong downward swipe
                        // Check if velocity is strong enough to close
                        if (velocity > 1000 &&
                            currentSize < widget.minHeightFactor * 1.5) {
                          _handleSheetClosing(
                              0); // Force close with strong downward swipe
                          return;
                        }
                        targetSize = widget.minHeightFactor;
                      } else {
                        // Based on position relative to midpoint
                        targetSize = currentSize > midPoint
                            ? widget.maxHeightFactor
                            : widget.minHeightFactor;
                      }

                      _dragController.animateTo(
                        targetSize,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      width: double.infinity,
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          height: 5,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: true,
                          child: widget.child,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
