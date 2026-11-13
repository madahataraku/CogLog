import 'conditional_advice_kind.dart';
import 'conditional_advice_metric.dart';

/// 条件付き定型の選択結果。埋め込み不要な条件では [metric] は null。
///
/// Example:
/// ```dart
/// ConditionalAdviceSelection(
///   kind: ConditionalAdviceKind.twoAchieved,
///   metric: ConditionalAdviceMetric.distance,
/// );
/// ```
final class ConditionalAdviceSelection {
  /// [kind] と任意の [metric] を持つ。
  ///
  /// Example:
  /// ```dart
  /// ConditionalAdviceSelection(
  ///   kind: ConditionalAdviceKind.welcomeBack,
  /// );
  /// ```
  const ConditionalAdviceSelection({required this.kind, this.metric});

  /// 使う定型グループ。
  final ConditionalAdviceKind kind;

  /// `{metric}` 置換に使う指標。不要な条件では null。
  final ConditionalAdviceMetric? metric;
}
