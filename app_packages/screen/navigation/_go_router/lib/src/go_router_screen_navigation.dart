import 'package:go_router/go_router.dart';
import 'package:screen_feature_exercise_history/screen_feature_exercise_history.dart';
import 'package:screen_feature_goal_settings/screen_feature_goal_settings.dart';
import 'package:screen_feature_main/screen_feature_main.dart';
import 'package:screen_feature_meter_capture/screen_feature_meter_capture.dart';
import 'package:screen_feature_top/screen_feature_top.dart';
import 'package:screen_navigation/screen_navigation.dart';

/// ボトムナビ 4 タブを [StatefulShellRoute.indexedStack] で組む。
///
/// Example:
/// ```dart
/// final navigation = GoRouterScreenNavigation();
/// navigation.router;
/// ```
final class GoRouterScreenNavigation implements ScreenNavigation {
  /// ルートを組む。
  ///
  /// Example:
  /// ```dart
  /// GoRouterScreenNavigation();
  /// ```
  GoRouterScreenNavigation()
    : router = GoRouter(
        initialLocation: '/',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) => ShellTabIndexScope(
              index: navigationShell.currentIndex,
              child: MainShellScreen(
                currentIndex: navigationShell.currentIndex,
                onIndexChange: (index) => navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                ),
                child: navigationShell,
              ),
            ),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const TopScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/meter-capture',
                    builder: (context, state) => const MeterCaptureScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/exercise-history',
                    builder: (context, state) => const ExerciseHistoryScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/goal-settings',
                    builder: (context, state) => const GoalSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  /// アプリが使うルーター。
  final GoRouter router;
}
