/// 一覧 1 行の表示用文字列。
///
/// Example:
/// ```dart
/// const ExerciseHistoryListItemEntity(
///   id: 'id',
///   caloriesText: '1.0',
///   durationText: '0h30m',
///   distanceText: '1.0',
///   createdAtText: '2026-11-05 12:00',
/// );
/// ```
final class ExerciseHistoryListItemEntity {
  /// 表示に使う ID と各欄の文字列を持つ。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryListItemEntity(
  ///   id: 'id',
  ///   caloriesText: '1.0',
  ///   durationText: '0h30m',
  ///   distanceText: '1.0',
  ///   createdAtText: '2026-11-05 12:00',
  /// );
  /// ```
  const ExerciseHistoryListItemEntity({
    required this.id,
    required this.caloriesText,
    required this.durationText,
    required this.distanceText,
    required this.createdAtText,
  });

  /// 詳細遷移に使う運動履歴 ID。
  final String id;

  /// 消費カロリーの表記。
  final String caloriesText;

  /// 運動時間の表記。
  final String durationText;

  /// 走行距離の表記。
  final String distanceText;

  /// 作成開始日時の表記。
  final String createdAtText;
}
