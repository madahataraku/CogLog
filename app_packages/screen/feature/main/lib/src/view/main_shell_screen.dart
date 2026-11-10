import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../strings.dart';

/// ボトムナビゲーションを持つアプリの入れ物。
///
/// go_router には依存しない。タブ切替は [onIndexChange] に任せる。
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
    return FScaffold(
      childPad: false,
      scaffoldStyle: .delta(footerDecoration: .value(const BoxDecoration())),
      footer: FBottomNavigationBar(
        safeAreaBottom: true,
        style: .delta(decoration: .value(const BoxDecoration())),
        index: currentIndex,
        onChange: onIndexChange,
        children: [
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.house),
            label: Text(strings.screen_feature_main_nav_home),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.camera),
            label: Text(strings.screen_feature_main_nav_meter_capture),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.chartLine),
            label: Text(strings.screen_feature_main_nav_trends),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.history),
            label: Text(strings.screen_feature_main_nav_exercise_history),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.target),
            label: Text(strings.screen_feature_main_nav_goal_settings),
          ),
        ],
      ),
      child: child,
    );
  }
}
