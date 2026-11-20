import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/profile_setup_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/groups/presentation/screens/groups_screen.dart';
import '../features/pomodoro/presentation/screens/pomodoro_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/statistics/presentation/screens/statistics_screen.dart';
import '../features/subjects/presentation/screens/subjects_screen.dart';
import '../features/timer/presentation/screens/timer_screen.dart';
import '../shared/widgets/app_scaffold.dart';
import 'route_names.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter provider managing navigation, route guards, and bottom/rail shell routes.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.value != null;
      final currentPath = state.uri.path;

      if (isLoading) return null;

      final isAuthRoute = currentPath == RouteNames.login ||
          currentPath == RouteNames.register ||
          currentPath == RouteNames.forgotPassword ||
          currentPath == RouteNames.onboarding ||
          currentPath == RouteNames.splash;

      if (!isAuthenticated && !isAuthRoute) {
        return RouteNames.login;
      }

      if (isAuthenticated && (currentPath == RouteNames.login || currentPath == RouteNames.register)) {
        return RouteNames.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.pomodoro,
        builder: (context, state) => const PomodoroScreen(),
      ),
      GoRoute(
        path: RouteNames.aiAssistant,
        builder: (context, state) => const AiAssistantScreen(),
      ),
      // Shell Route for persistent Navigation Bar / Rail
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.timer,
            builder: (context, state) => const TimerScreen(),
          ),
          GoRoute(
            path: RouteNames.subjects,
            builder: (context, state) => const SubjectsScreen(),
          ),
          GoRoute(
            path: RouteNames.statistics,
            builder: (context, state) => const StatisticsScreen(),
          ),
          GoRoute(
            path: RouteNames.groups,
            builder: (context, state) => const GroupsScreen(),
          ),
        ],
      ),
    ],
  );
});
