import 'advice_tone.dart';

/// 生成したワンポイントアドバイス。
///
/// Example:
/// ```dart
/// const GenerateTopAdviceResult(
///   advice: '水分を取ろう',
///   tone: AdviceTone.fun,
/// );
/// ```
final class GenerateTopAdviceResult {
  /// [advice] と [tone] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const GenerateTopAdviceResult(
  ///   advice: '水分を取ろう',
  ///   tone: AdviceTone.fun,
  /// );
  /// ```
  const GenerateTopAdviceResult({required this.advice, required this.tone});

  /// 画面に出す短い助言。
  final String advice;

  /// 助言に対応する表情トーン。
  final AdviceTone tone;
}
