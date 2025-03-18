import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/features/add/views/widgets/add_task_widget.dart';
import 'package:go_router/go_router.dart';

class NavigationBottomBarWidget extends StatefulWidget {
  const NavigationBottomBarWidget({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<NavigationBottomBarWidget> createState() =>
      _NavigationBottomBarWidgetState();
}

class _NavigationBottomBarWidgetState extends State<NavigationBottomBarWidget> {
  final List<int> _navigationStack = [];

  void _onDestinationSelected(int index) {
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _onDestinationSelected,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return const AddTaskWidget(); // Open AddTaskWidget
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
