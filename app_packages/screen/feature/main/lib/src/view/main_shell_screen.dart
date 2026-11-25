import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

import '../strings.dart';

/// ボトムナビゲーションを持つアプリの入れ物。
///
/// go_router には依存しない。タブ切替は [onIndexChange] に任せる。
/// キーボード表示中はボトムナビを隠し、子へ bottom inset を伝播させない。
///
/// Example:
/// ```dart
/// MainShellScreen(
///   currentIndex: 0,
///   onIndexChange: (_) {},
///   child: const SizedBox.shrink(),
/// );
/// ```
class MainShellScreen extends StatelessWidget {
  /// [currentIndex] のタブを選び、[child] を本文に置く。
  ///
  /// Example:
  /// ```dart
  /// MainShellScreen(
  ///   currentIndex: 0,
  ///   onIndexChange: (_) {},
  ///   child: const SizedBox.shrink(),
  /// );
  /// ```
  const MainShellScreen({
    required this.currentIndex,
    required this.onIndexChange,
    required this.child,
    super.key,
  });

  /// 選択中のタブ。
  final int currentIndex;

  /// タブが選ばれたときに呼ぶ。
  final ValueChanged<int> onIndexChange;

  /// 選択中タブの中身。
  final Widget child;

  /// フッターにボトムナビを付けて [child] を出す。
  ///
  /// Example:
  /// ```dart
  /// MainShellScreen(
  ///   currentIndex: 0,
  ///   onIndexChange: (_) {},
  ///   child: const SizedBox.shrink(),
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return FScaffold(
      childPad: false,
      scaffoldStyle: .delta(footerDecoration: .value(const BoxDecoration())),
      resizeToAvoidBottomInset: true,
      footer: keyboardVisible
          ? null
          : FBottomNavigationBar(
              safeAreaBottom: true,
              style: .delta(decoration: .value(const BoxDecoration())),
              index: currentIndex,
              onChange: onIndexChange,
              children: [
                CoachMarkTarget(
                  id: CoachMarkTargetId.navHome,
                  child: FBottomNavigationBarItem(
                    icon: const Icon(FLucideIcons.house),
                    label: Text(strings.screen_feature_main_nav_home),
                  ),
                ),
                CoachMarkTarget(
                  id: CoachMarkTargetId.navMeterCapture,
                  child: FBottomNavigationBarItem(
                    icon: const Icon(FLucideIcons.camera),
                    label: Text(strings.screen_feature_main_nav_meter_capture),
                  ),
                ),
                CoachMarkTarget(
                  id: CoachMarkTargetId.navTrends,
                  child: FBottomNavigationBarItem(
                    icon: const Icon(FLucideIcons.chartLine),
                    label: Text(strings.screen_feature_main_nav_trends),
                  ),
                ),
                CoachMarkTarget(
                  id: CoachMarkTargetId.navExerciseHistory,
                  child: FBottomNavigationBarItem(
                    icon: const Icon(FLucideIcons.history),
                    label: Text(
                      strings.screen_feature_main_nav_exercise_history,
                    ),
                  ),
                ),
                CoachMarkTarget(
                  id: CoachMarkTargetId.navGoalSettings,
                  child: FBottomNavigationBarItem(
                    icon: const Icon(FLucideIcons.target),
                    label: Text(strings.screen_feature_main_nav_goal_settings),
                  ),
                ),
              ],
            ),
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: child,
      ),
    );
  }
}
