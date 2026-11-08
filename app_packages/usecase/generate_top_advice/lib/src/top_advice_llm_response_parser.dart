import 'generate_top_advice_result.dart';

/// LLM 生テキストから本文とトーンを取り出す。
///
/// Example:
/// ```dart
/// parser.parse('TONE=fun\\nADVICE=水分を取ろう');
/// ```
abstract interface class TopAdviceLlmResponseParser {
  /// [raw] を解析して [GenerateTopAdviceResult] にする。
  ///
  /// Example:
  /// ```dart
  /// parser.parse('TONE=fun\\nADVICE=水分を取ろう');
  /// ```
  GenerateTopAdviceResult parse(String raw);
}
