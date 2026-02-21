import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/practice/practice_screen.dart';
import 'screens/browse/browse_screen.dart';
import 'screens/browse/card_detail_screen.dart';
import 'screens/statistics/statistics_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/shell/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

bool _isOnboardingComplete() {
  try {
    final box = Hive.box('app_settings');
    return box.get('onboarding_complete', defaultValue: false) as bool;
  } catch (_) {
    return false;
  }
}

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    if (state.uri.path == '/' && !_isOnboardingComplete()) {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // Branch 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Branch 1 — Practice
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/practice',
              builder: (context, state) => const PracticeScreen(),
              routes: [
                GoRoute(
                  path: ':cardId',
                  builder: (context, state) {
                    final cardId = state.pathParameters['cardId']!;
                    return PracticeScreen(cardId: cardId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch 2 — Browse
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/browse',
              builder: (context, state) => const BrowseScreen(),
              routes: [
                GoRoute(
                  path: ':cardId',
                  builder: (context, state) {
                    final cardId = state.pathParameters['cardId']!;
                    return CardDetailScreen(cardId: cardId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch 3 — Statistics
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statistics',
              builder: (context, state) => const StatisticsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class SeerSchoolApp extends StatelessWidget {
  const SeerSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Seer School',
      theme: AppTheme.theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
