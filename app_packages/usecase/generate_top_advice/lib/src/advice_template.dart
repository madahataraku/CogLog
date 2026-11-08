import 'advice_tone.dart';

/// 定型アドバイス本文とトーンの組。
///
/// Example:
/// ```dart
/// const AdviceTemplate(text: '水分を取ろう', tone: AdviceTone.fun);
/// ```
final class AdviceTemplate {
  /// [text] と [tone] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const AdviceTemplate(text: '水分を取ろう', tone: AdviceTone.fun);
  /// ```
  const AdviceTemplate({required this.text, required this.tone});

  /// 吹き出しに出す本文。
  final String text;

  /// 本文に対応する表情トーン。
  final AdviceTone tone;
}
