import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/screens/login_screen.dart';
import 'package:flutter_life_goal_management/src/screens/forgot_password_screen.dart';
import 'package:flutter_life_goal_management/src/screens/sign_up_screen.dart';
import 'package:flutter_life_goal_management/src/screens/home_screen.dart';
import 'package:flutter_life_goal_management/src/screens/explore_screen.dart';
import 'package:flutter_life_goal_management/src/screens/calendar_screen.dart';
import 'package:flutter_life_goal_management/src/widgets/scaffold_with_bottom_navbar_widget.dart';
import 'package:flutter_life_goal_management/src/screens/profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';
import 'package:flutter_life_goal_management/src/services/http_service.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  initialLocation: '/',
  navigatorKey: HttpService.navigatorKey,
  redirect: (context, state) async {
    // Get unprotected routes
    final publicRoutes = ['/login', '/login/forgot-password', '/login/sign-up'];

    // Check if the current location is in the public routes
    final isPublicRoute = publicRoutes.contains(state.fullPath);

    // Check if token exists and is valid
    final isLoggedIn = await AuthService().loggedIn();
    print('isLoggedIn: $isLoggedIn, route: ${state.fullPath}');

    // If not logged in and trying to access a protected route
    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    // If logged in and trying to access an auth route
    if (isLoggedIn && isPublicRoute) {
      return '/';
    }

    // No redirection needed
    return null;
  },
  routes: <RouteBase>[
    // Auth branch
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen(title: 'Login Screen');
      },
      routes: [
        // Nested routes under login
        GoRoute(
          path: 'forgot-password',
          builder: (BuildContext context, GoRouterState state) {
            return const ForgotPasswordScreen(title: 'Forgot Password');
          },
        ),
        GoRoute(
          path: 'sign-up',
          builder: (BuildContext context, GoRouterState state) {
            return const SignUpScreen(title: 'Sign Up');
          },
        ),
      ],
    ),
    // Main shell route for bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithBottomNavBarWidget(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return const HomeScreen(title: 'Home');
              },
            ),
          ],
        ),
        // Explore branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (BuildContext context, GoRouterState state) {
                return const ExploreScreen(title: 'Explore');
              },
            ),
          ],
        ),
        // Community branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (BuildContext context, GoRouterState state) {
                return const CalendarScreen(title: 'Calendar');
              },
            ),
          ],
        ),
        // Profile branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) {
                return const ProfileScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
