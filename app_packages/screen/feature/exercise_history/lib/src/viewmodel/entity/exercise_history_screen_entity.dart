import 'exercise_history_list_item_entity.dart';

/// 運動履歴一覧の表示用状態。
///
/// Example:
/// ```dart
/// const ExerciseHistoryScreenEntity(
///   monthLabel: '2026年11月',
///   items: [],
///   showEmpty: true,
///   showLoading: false,
///   showLoadMoreSpinner: false,
///   errorText: null,
///   loadMoreErrorText: null,
///   canRetry: false,
///   canRetryLoadMore: false,
/// );
/// ```
final class ExerciseHistoryScreenEntity {
  /// 月ラベルとリストと表示フラグを持つ。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryScreenEntity(
  ///   monthLabel: '2026年11月',
  ///   items: [],
  ///   showEmpty: true,
  ///   showLoading: false,
  ///   showLoadMoreSpinner: false,
  ///   errorText: null,
  ///   loadMoreErrorText: null,
  ///   canRetry: false,
  ///   canRetryLoadMore: false,
  /// );
  /// ```
  const ExerciseHistoryScreenEntity({
    required this.monthLabel,
    required this.items,
    required this.showEmpty,
    required this.showLoading,
    required this.showLoadMoreSpinner,
    required this.errorText,
    required this.loadMoreErrorText,
    required this.canRetry,
    required this.canRetryLoadMore,
  });

  /// 月セレクタに出すラベル。
  final String monthLabel;

  /// 表示する行。
  final List<ExerciseHistoryListItemEntity> items;

  /// 空文言を出すか。
  final bool showEmpty;

  /// 初回読込のスピナーを出すか。
  final bool showLoading;

  /// 末尾の追加読込スピナーを出すか。
  final bool showLoadMoreSpinner;

  /// 初回失敗の文言。無ければ null。
  final String? errorText;

  /// 追加失敗の文言。無ければ null。
  final String? loadMoreErrorText;

  /// 初回失敗の再試行を出せるか。
  final bool canRetry;

  /// 追加失敗の再試行を出せるか。
  final bool canRetryLoadMore;
}
