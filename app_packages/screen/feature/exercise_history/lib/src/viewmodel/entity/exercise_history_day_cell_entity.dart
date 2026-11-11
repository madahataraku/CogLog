/// カレンダー 1 マスの表示用状態。
///
/// Example:
/// ```dart
/// const ExerciseHistoryDayCellEntity(
///   day: 5,
///   stampCount: 2,
///   isTappable: true,
///   semanticsLabel: '5日、運動履歴2件',
/// );
/// ```
final class ExerciseHistoryDayCellEntity {
  /// 日付・スタンプ件数・タップ可否・読み上げ文言を持つ。
  ///
  /// [day] が null のとき前後月の空白マスで、数字は出さない。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryDayCellEntity(
  ///   day: 5,
  ///   stampCount: 2,
  ///   isTappable: true,
  ///   semanticsLabel: '5日、運動履歴2件',
  /// );
  /// ```
  const ExerciseHistoryDayCellEntity({
    required this.day,
    required this.stampCount,
    required this.isTappable,
    required this.semanticsLabel,
  });

  /// 選択月内の日。空白マスは null。
  final int? day;

  /// その日の運動履歴件数。0 なら印なし。
  final int stampCount;

  /// スタンプがありタップで詳細へ進めるか。
  final bool isTappable;

  /// VoiceOver 等に渡すラベル。
  final String semanticsLabel;
}
