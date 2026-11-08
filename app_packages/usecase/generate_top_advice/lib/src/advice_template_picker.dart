import 'advice_template.dart';

/// 定型アドバイスから 1 件を選ぶ。
///
/// 本番は乱数、テストは固定実装を注入する。
///
/// Example:
/// ```dart
/// picker.pick(const [
///   AdviceTemplate(text: 'a', tone: AdviceTone.fun),
/// ]);
/// ```
abstract interface class AdviceTemplatePicker {
  /// [templates] から 1 件を返す。[templates] は空でないこと。
  ///
  /// Example:
  /// ```dart
  /// picker.pick(const [
  ///   AdviceTemplate(text: 'a', tone: AdviceTone.fun),
  /// ]);
  /// ```
  AdviceTemplate pick(List<AdviceTemplate> templates);
}
