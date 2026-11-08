import 'dart:math';

import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

/// 乱数で定型を 1 件選ぶ。
///
/// Example:
/// ```dart
/// RandomAdviceTemplatePicker();
/// ```
final class RandomAdviceTemplatePicker implements AdviceTemplatePicker {
  /// [random] を省略すると新しい [Random] を使う。
  ///
  /// Example:
  /// ```dart
  /// RandomAdviceTemplatePicker(random: Random(0));
  /// ```
  RandomAdviceTemplatePicker({Random? random}) : _random = random ?? Random();

  /// 選択に使う乱数源。テストでは seed 固定の [Random] を渡せる。
  final Random _random;

  /// [templates] から一様に 1 件選ぶ。空の [templates] は [ArgumentError]。
  ///
  /// Example:
  /// ```dart
  /// RandomAdviceTemplatePicker().pick(const [
  ///   AdviceTemplate(text: 'a', tone: AdviceTone.fun),
  /// ]);
  /// ```
  @override
  AdviceTemplate pick(List<AdviceTemplate> templates) {
    if (templates.isEmpty) {
      throw ArgumentError.value(templates, 'templates', 'must not be empty');
    }
    return templates[_random.nextInt(templates.length)];
  }
}
