import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

/// 今週の目標達成日数の横長ゲージ、または設定誘導。
@internal
class WeeklyGoalAchievementBar extends StatelessWidget {
  /// 誘導またはゲージを表示する。
  ///
  /// Example:
  /// ```dart
  /// WeeklyGoalAchievementBar(
  ///   title: '今週の目標達成日数',
  ///   showGuidance: false,
  ///   guidanceText: '',
  ///   ratioText: '2/5',
  ///   progress: 0.4,
  ///   semanticsLabel: '残り3日',
  /// );
  /// ```
  const WeeklyGoalAchievementBar({
    required this.title,
    required this.showGuidance,
    required this.guidanceText,
    required this.ratioText,
    required this.progress,
    required this.semanticsLabel,
    super.key,
  });

  /// 見出し。
  final String title;

  /// 設定誘導を出すとき true。
  final bool showGuidance;

  /// 誘導文言。
  final String guidanceText;

  /// `n/m` 表記。
  final String ratioText;

  /// ゲージ進捗 0〜1。
  final double progress;

  /// 残り日数などを含む semantics。
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.theme.typography.body.sm.copyWith(
      fontWeight: FontWeight.w600,
    );
    if (showGuidance) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(title, style: titleStyle),
          Text(
            guidanceText,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      );
    }
    return Semantics(
      label: semanticsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(title, style: titleStyle),
          LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
          Text(ratioText, style: context.theme.typography.body.sm),
        ],
      ),
    );
  }
}
