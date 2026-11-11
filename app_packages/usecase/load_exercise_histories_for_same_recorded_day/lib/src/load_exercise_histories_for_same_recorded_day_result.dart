/// 同一記録日の ID 列、または不在。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoriesForSameRecordedDayNotFound();
/// ```
sealed class LoadExerciseHistoriesForSameRecordedDayResult {
  /// 共通の封印コンストラクタ。
  const LoadExerciseHistoriesForSameRecordedDayResult();
}

/// 対象 ID が見つからない。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoriesForSameRecordedDayNotFound();
/// ```
final class LoadExerciseHistoriesForSameRecordedDayNotFound
    extends LoadExerciseHistoriesForSameRecordedDayResult {
  /// 不在結果を作る。
  ///
  /// Example:
  /// ```dart
  /// const LoadExerciseHistoriesForSameRecordedDayNotFound();
  /// ```
  const LoadExerciseHistoriesForSameRecordedDayNotFound();
}

/// 同一記録日の ID 列と初期位置。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoriesForSameRecordedDaySuccess(
///   ids: ['a'],
///   initialIndex: 0,
/// );
/// ```
final class LoadExerciseHistoriesForSameRecordedDaySuccess
    extends LoadExerciseHistoriesForSameRecordedDayResult {
  /// [ids] と [initialIndex] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const LoadExerciseHistoriesForSameRecordedDaySuccess(
  ///   ids: ['a'],
  ///   initialIndex: 0,
  /// );
  /// ```
  const LoadExerciseHistoriesForSameRecordedDaySuccess({
    required this.ids,
    required this.initialIndex,
  });

  /// 作成開始日時の降順の ID 列。
  final List<String> ids;

  /// [ids] 内の要求 ID の位置。
  final int initialIndex;
}
