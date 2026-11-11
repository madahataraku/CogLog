import 'exercise_history_day_cell_entity.dart';

/// 運動履歴カレンダーの表示用状態。
///
/// Example:
/// ```dart
/// const ExerciseHistoryScreenEntity(
///   monthLabel: '2026年11月',
///   weekdayLabels: ['月', '火', '水', '木', '金', '土', '日'],
///   dayCells: [],
///   showLoading: false,
///   showError: false,
///   errorText: null,
///   canRetry: false,
/// );
/// ```
final class ExerciseHistoryScreenEntity {
  /// 月ラベル・曜日・セル・表示フラグを持つ。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryScreenEntity(
  ///   monthLabel: '2026年11月',
  ///   weekdayLabels: ['月', '火', '水', '木', '金', '土', '日'],
  ///   dayCells: [],
  ///   showLoading: false,
  ///   showError: false,
  ///   errorText: null,
  ///   canRetry: false,
  /// );
  /// ```
  const ExerciseHistoryScreenEntity({
    required this.monthLabel,
    required this.weekdayLabels,
    required this.dayCells,
    required this.showLoading,
    required this.showError,
    required this.errorText,
    required this.canRetry,
  });

  /// 月セレクタに出すラベル。
  final String monthLabel;

  /// 月曜始まりの曜日ヘッダ（長さ 7）。
  final List<String> weekdayLabels;

  /// 月曜始まりグリッドのセル。
  final List<ExerciseHistoryDayCellEntity> dayCells;

  /// カレンダー領域に進捗を出すか。
  final bool showLoading;

  /// エラーと再試行を出すか。
  final bool showError;

  /// 失敗時の文言。無ければ null。
  final String? errorText;

  /// 再試行を出せるか。
  final bool canRetry;
}
