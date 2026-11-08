import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 詳細読み込みの結果。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoryDetailNotFound();
/// ```
sealed class LoadExerciseHistoryDetailResult {
  /// 結果の共通口。
  const LoadExerciseHistoryDetailResult();
}

/// 対象が無い。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoryDetailNotFound();
/// ```
final class LoadExerciseHistoryDetailNotFound
    extends LoadExerciseHistoryDetailResult {
  /// 不在を表す。
  ///
  /// Example:
  /// ```dart
  /// const LoadExerciseHistoryDetailNotFound();
  /// ```
  const LoadExerciseHistoryDetailNotFound();
}

/// 詳細の成功結果。
///
/// Example:
/// ```dart
/// LoadExerciseHistoryDetailSuccess(
///   history: history,
///   photoAbsolutePath: null,
/// );
/// ```
final class LoadExerciseHistoryDetailSuccess
    extends LoadExerciseHistoryDetailResult {
  /// [history] と任意の写真パスを持つ。
  ///
  /// Example:
  /// ```dart
  /// LoadExerciseHistoryDetailSuccess(
  ///   history: history,
  ///   photoAbsolutePath: null,
  /// );
  /// ```
  const LoadExerciseHistoryDetailSuccess({
    required this.history,
    required this.photoAbsolutePath,
  });

  /// 対象の運動履歴。
  final ExerciseHistory history;

  /// 写真の絶対パス。ファイルが無ければ null。
  final String? photoAbsolutePath;
}
