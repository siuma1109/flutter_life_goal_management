import 'package:flutter/material.dart';
import 'package:flutter_life_goal_management/src/features/auth/views/screens/login_screen.dart';
import 'package:flutter_life_goal_management/src/features/auth/views/screens/forgot_password_screen.dart';
import 'package:flutter_life_goal_management/src/features/auth/views/screens/sign_up_screen.dart';
import 'package:flutter_life_goal_management/src/features/navigation_bottom_bar/views.widgets/navigation_bottom_bar.dart';
import 'package:flutter_life_goal_management/src/features/home.views.screens/home_screen.dart';
import 'package:flutter_life_goal_management/src/features/explore/views/screens/explore_screen.dart';
import 'package:flutter_life_goal_management/src/features/add/views/screens/add_screen.dart';
import 'package:flutter_life_goal_management/src/features/community/views/screens/community_screen.dart';
import 'package:flutter_life_goal_management/src/features/profile/views/screens/profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_life_goal_management/src/services/auth_service.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = AuthService().isLoggedIn();
    final location = state.fullPath;

    // Check if current route is any of the auth routes
    final isLoginRoute = location?.contains('login') ?? false;

    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    } else if (isLoggedIn && isLoginRoute) {
      return '/';
    }

    return null; // No redirection needed
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
        return NavigationBottomBarWidget(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
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
        // Explore branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (BuildContext context, GoRouterState state) {
                return const ExploreScreen(title: 'Explore Screen');
              },
            ),
          ],
        ),
        // Add branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/add',
              builder: (BuildContext context, GoRouterState state) {
                return const AddScreen(title: 'Add Screen');
              },
            ),
          ],
        ),
        // Community branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              builder: (BuildContext context, GoRouterState state) {
                return const CommunityScreen(title: 'Community Screen');
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
                return const ProfileScreen(title: 'Profile Screen');
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
