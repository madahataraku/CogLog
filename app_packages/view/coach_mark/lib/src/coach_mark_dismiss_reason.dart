/// コーチマークを閉じた理由。
///
/// Example:
/// ```dart
/// CoachMarkDismissReason.primary;
/// ```
enum CoachMarkDismissReason {
  /// 主ボタン。
  primary,

  /// 副ボタン。
  secondary,

  /// OS 戻る。
  systemBack,

  /// 強制破棄（再表示タイル・文脈割り込みなど）。
  forced,
}
