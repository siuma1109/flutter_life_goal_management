import 'package:flutter/material.dart';

/// A reusable loading overlay component that covers the screen when loading state is needed
class LoadingOverlay extends StatelessWidget {
  /// Whether to show the loading indicator
  final bool isLoading;

  /// Text to display below the loading indicator
  final String? loadingText;

  /// Background color of the overlay
  final Color? backgroundColor;

  /// Color of the loading indicator
  final Color? indicatorColor;

  /// Text color
  final Color? textColor;

  /// Child widget to be overlaid
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.backgroundColor,
    this.indicatorColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor ?? Colors.black.withOpacity(0.5),
              child: Center(
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: screenSize.width * 0.8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            indicatorColor ??
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (loadingText != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            loadingText!,
                            style: TextStyle(
                              color: textColor ?? Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
