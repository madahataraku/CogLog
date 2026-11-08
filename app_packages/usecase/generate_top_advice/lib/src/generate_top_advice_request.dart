import 'package:domain_exercise_history/domain_exercise_history.dart';

import 'advice_template.dart';

/// ワンポイントアドバイス生成の依頼。
///
/// [fallbackTemplates] は LLM 不可・失敗時用で 3 件以上あること。
///
/// Example:
/// ```dart
/// GenerateTopAdviceRequest(
///   histories: const [],
///   locale: 'ja',
///   noExercise: AdviceTemplate(
///     text: '今日はまだ運動していません',
///     tone: AdviceTone.realized,
///   ),
///   fallbackTemplates: const [
///     AdviceTemplate(text: 'a', tone: AdviceTone.fun),
///     AdviceTemplate(text: 'b', tone: AdviceTone.happy),
///     AdviceTemplate(text: 'c', tone: AdviceTone.fun),
///   ],
/// );
/// ```
final class GenerateTopAdviceRequest {
  /// 本日履歴・言語・未運動定型・フォールバック定型を持つ。
  ///
  /// Example:
  /// ```dart
  /// GenerateTopAdviceRequest(
  ///   histories: const [],
  ///   locale: 'ja',
  ///   noExercise: AdviceTemplate(
  ///     text: '今日はまだ運動していません',
  ///     tone: AdviceTone.realized,
  ///   ),
  ///   fallbackTemplates: const [
  ///     AdviceTemplate(text: 'a', tone: AdviceTone.fun),
  ///     AdviceTemplate(text: 'b', tone: AdviceTone.happy),
  ///     AdviceTemplate(text: 'c', tone: AdviceTone.fun),
  ///   ],
  /// );
  /// ```
  const GenerateTopAdviceRequest({
    required this.histories,
    required this.locale,
    required this.noExercise,
    required this.fallbackTemplates,
  });

  /// 本日の運動履歴。空なら未運動定型を使う。
  final List<ExerciseHistory> histories;

  /// 言語コード（例: ja / en）。
  final String locale;

  /// 履歴 0 件のときに返す定型（本文＋トーン）。
  final AdviceTemplate noExercise;

  /// LLM 不可・失敗時に選ぶ定型（3 件以上）。
  final List<AdviceTemplate> fallbackTemplates;
}
