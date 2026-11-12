/// 運動履歴編集画面を閉じたときの結果。
///
/// 破棄やシステム戻りのときは [ScreenNavigation.openExerciseHistoryEditAndWait]
/// が null を返す。[saved] が真のときだけ詳細側が再読込またはカレンダーへ戻る。
///
/// Example:
/// ```dart
/// const ExerciseHistoryEditPopResult(
///   saved: true,
///   recordedLocalDayChanged: false,
/// );
/// ```
final class ExerciseHistoryEditPopResult {
  /// 保存の成否と、記録日時の現地暦日が変わったかを持つ。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryEditPopResult(
  ///   saved: true,
  ///   recordedLocalDayChanged: false,
  /// );
  /// ```
  const ExerciseHistoryEditPopResult({
    required this.saved,
    required this.recordedLocalDayChanged,
  });

  /// 更新が成功して閉じたか。
  final bool saved;

  /// 記録日時の現地暦日が編集前後で変わったか。
  final bool recordedLocalDayChanged;
}
