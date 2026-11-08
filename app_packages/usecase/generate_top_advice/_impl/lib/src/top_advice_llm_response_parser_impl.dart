import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

/// `TONE=` / `ADVICE=` 行形式を読む既定パーサ。
///
/// Example:
/// ```dart
/// const TopAdviceLlmResponseParserImpl();
/// ```
final class TopAdviceLlmResponseParserImpl
    implements TopAdviceLlmResponseParser {
  /// 差し替え可能な既定実装を作る。
  ///
  /// Example:
  /// ```dart
  /// const TopAdviceLlmResponseParserImpl();
  /// ```
  const TopAdviceLlmResponseParserImpl();

  /// [raw] からトーンと本文を取り出す。未知トーンは [AdviceTone.fun]。
  ///
  /// `ADVICE=` 以降の行は本文に連結する。行形式が欠けるときは `TONE=` 行を除いた
  /// [raw] 全体を本文とする。
  ///
  /// Example:
  /// ```dart
  /// const TopAdviceLlmResponseParserImpl().parse(
  ///   'TONE=happy\nADVICE=よく動けた',
  /// );
  /// ```
  @override
  GenerateTopAdviceResult parse(String raw) {
    String? toneRaw;
    final adviceLines = <String>[];
    var inAdvice = false;
    for (final line in raw.split('\n')) {
      final trimmed = line.trimRight();
      final upper = trimmed.trimLeft().toUpperCase();
      if (upper.startsWith('TONE=')) {
        toneRaw = trimmed.trimLeft().substring(5).trim();
        inAdvice = false;
        continue;
      }
      if (upper.startsWith('ADVICE=')) {
        adviceLines
          ..clear()
          ..add(trimmed.trimLeft().substring(7));
        inAdvice = true;
        continue;
      }
      if (inAdvice) {
        adviceLines.add(trimmed);
      }
    }
    final advice = adviceLines.isEmpty
        ? raw
              .split('\n')
              .where((l) => !l.trimLeft().toUpperCase().startsWith('TONE='))
              .join('\n')
              .trim()
        : adviceLines.join('\n').trim();
    return GenerateTopAdviceResult(
      advice: advice,
      tone: AdviceTone.parse(toneRaw ?? ''),
    );
  }
}
