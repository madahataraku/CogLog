import 'package:meta/meta.dart';

/// 運動履歴編集画面の表示フェーズ。
///
/// form は既存の編集入力。camera は同一画面内のアプリ内カメラ。
///
/// Example:
/// ```dart
/// ExerciseHistoryEditPhase.form;
/// ```
@internal
enum ExerciseHistoryEditPhase {
  /// 編集入力。
  form,

  /// アプリ内カメラ。
  camera,
}
