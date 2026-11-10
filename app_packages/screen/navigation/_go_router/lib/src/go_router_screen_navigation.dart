import 'package:go_router/go_router.dart';
import 'package:screen_feature_app_settings/screen_feature_app_settings.dart';
import 'package:screen_feature_debug/screen_feature_debug.dart';
import 'package:screen_feature_exercise_history/screen_feature_exercise_history.dart';
import 'package:screen_feature_exercise_history_detail/screen_feature_exercise_history_detail.dart';
import 'package:screen_feature_goal_settings/screen_feature_goal_settings.dart';
import 'package:screen_feature_main/screen_feature_main.dart';
import 'package:screen_feature_meter_capture/screen_feature_meter_capture.dart';
import 'package:screen_feature_top/screen_feature_top.dart';
import 'package:screen_feature_trends/screen_feature_trends.dart';
import 'package:screen_navigation/screen_navigation.dart';

/// ボトムナビ 5 タブを [StatefulShellRoute.indexedStack] で組む。
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
  GoRouterScreenNavigation() {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            _shell = navigationShell;
            return ShellTabIndexScope(
              index: navigationShell.currentIndex,
              child: MainShellScreen(
                currentIndex: navigationShell.currentIndex,
                onIndexChange: (index) => navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                ),
                child: navigationShell,
              ),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const TopScreen(),
                  routes: [
                    GoRoute(
                      path: 'settings',
                      builder: (context, state) => const AppSettingsScreen(),
                      routes: [
                        GoRoute(
                          path: 'debug',
                          builder: (context, state) => const DebugScreen(),
                        ),
                      ],
                    ),
                  ],
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
                  path: '/trends',
                  builder: (context, state) => const TrendsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/exercise-history',
                  builder: (context, state) => const ExerciseHistoryScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail/:id',
                      builder: (context, state) => ExerciseHistoryDetailScreen(
                        id: state.pathParameters['id']!,
                      ),
                    ),
                  ],
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
  }

  /// アプリが使うルーター。
  late final GoRouter router;

  /// タブ切替に使うシェル。初回ビルドまで未設定。
  StatefulNavigationShell? _shell;

  /// 運動履歴詳細をタブ内スタックへ積む。
  ///
  /// Example:
  /// ```dart
  /// navigation.openExerciseHistoryDetail(id: 'id');
  /// ```
  @override
  void openExerciseHistoryDetail({required String id}) {
    router.push('/exercise-history/detail/$id');
  }

  /// アプリ設定をホームタブのスタックへ積む。
  ///
  /// Example:
  /// ```dart
  /// navigation.openAppSettings();
  /// ```
  @override
  void openAppSettings() {
    router.push('/settings');
  }

  /// デバッグ画面を積む。
  ///
  /// Example:
  /// ```dart
  /// navigation.openDebug();
  /// ```
  @override
  void openDebug() {
    router.push('/settings/debug');
  }

  /// 現在のスタックを 1 つ戻す。
  ///
  /// Example:
  /// ```dart
  /// navigation.pop();
  /// ```
  @override
  void pop() {
    router.pop();
  }

  /// ホームタブの初期位置へ切り替える。
  ///
  /// Example:
  /// ```dart
  /// navigation.goToHomeTab();
  /// ```
  @override
  void goToHomeTab() {
    _shell?.goBranch(0, initialLocation: true);
  }
}
