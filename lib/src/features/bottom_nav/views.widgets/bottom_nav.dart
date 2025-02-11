import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavWidget extends StatefulWidget {
  const BottomNavWidget({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<BottomNavWidget> createState() => _BottomNavWidgetState();
}

class _BottomNavWidgetState extends State<BottomNavWidget> {
  final List<int> _navigationStack = [];

  void _onTap(BuildContext context, int index) {
    if (index != widget.navigationShell.currentIndex) {
      setState(() {
        _navigationStack.add(widget.navigationShell.currentIndex);
      });
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Future<bool> _onWillPop() async {
    if (_navigationStack.isEmpty) {
      return true; // Allow app to close
    }

    setState(() {
      final lastIndex = _navigationStack.removeLast();
      widget.navigationShell.goBranch(
        lastIndex,
        initialLocation: lastIndex == widget.navigationShell.currentIndex,
      );
    });
    return false; // Prevent app from closing
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _navigationStack.isEmpty,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) => _onTap(context, index),
          backgroundColor: const Color(0xffe0b9f6),
          currentIndex: widget.navigationShell.currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          ],
        ),
      ),
    );
  }
}
