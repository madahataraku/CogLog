import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

/// 今週の目標達成日数の横長ゲージ、または設定誘導。
///
/// [showGuidance] が true のときはゲージの代わりに案内だけを出す。
///
/// Example:
/// ```dart
/// WeeklyGoalAchievementBar(
///   title: '今週の目標達成日数',
///   showGuidance: false,
///   guidanceText: '',
///   ratioText: '達成日数:2日 / 目標日数:5日',
///   statusText: '目標達成まであと3日！',
///   progress: 0.4,
///   semanticsLabel: '残り3日',
/// );
/// ```
@internal
class WeeklyGoalAchievementBar extends StatelessWidget {
  /// 誘導またはゲージを表示する。
  ///
  /// [progress] は 0〜1。[showGuidance] が true のときは比・ゲージ・状態は使わない。
  ///
  /// Example:
  /// ```dart
  /// WeeklyGoalAchievementBar(
  ///   title: '今週の目標達成日数',
  ///   showGuidance: false,
  ///   guidanceText: '',
  ///   ratioText: '達成日数:2日 / 目標日数:5日',
  ///   statusText: '目標達成まであと3日！',
  ///   progress: 0.4,
  ///   semanticsLabel: '残り3日',
  /// );
  /// ```
  const WeeklyGoalAchievementBar({
    required this.title,
    required this.showGuidance,
    required this.guidanceText,
    required this.ratioText,
    required this.statusText,
    required this.progress,
    required this.semanticsLabel,
    super.key,
  });

  /// ゲージまたは誘導の上部見出し。
  final String title;

  /// 目標未設定などで設定誘導を出すとき true。
  final bool showGuidance;

  /// [showGuidance] が true のときに出す案内文。
  final String guidanceText;

  /// 達成日数と目標日数の比表記。
  final String ratioText;

  /// 残り日数または達成済の文言。
  final String statusText;

  /// ゲージ進捗（0〜1。描画時に clamp する）。
  final double progress;

  /// スクリーンリーダー向け。残り日数などを含む。
  final String semanticsLabel;

  /// 誘導時は見出しと案内、それ以外は比・ゲージ・状態を縦に並べる。
  ///
  /// Example:
  /// ```dart
  /// WeeklyGoalAchievementBar(
  ///   title: '今週の目標達成日数',
  ///   showGuidance: true,
  ///   guidanceText: '目標を設定しましょう',
  ///   ratioText: '',
  ///   statusText: '',
  ///   progress: 0,
  ///   semanticsLabel: '',
  /// );
  /// ```
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
          Text(ratioText, style: context.theme.typography.body.sm),
          LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
          Text(statusText, style: context.theme.typography.body.sm),
        ],
      ),
    );
  }
}
