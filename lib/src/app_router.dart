import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/features/auth/views/screens/login_screen.dart';
import 'package:flutter_life_goal_management/src/features/bottom_nav/views.widgets/bottom_nav.dart';
import 'package:flutter_life_goal_management/src/features/home.views.screens/home_screen.dart';
import 'package:go_router/go_router.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavWidget(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return const HomeScreen(title: 'Home Screen');
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/login',
              builder: (BuildContext context, GoRouterState state) {
                return const LoginScreen(title: 'Login Screen');
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
