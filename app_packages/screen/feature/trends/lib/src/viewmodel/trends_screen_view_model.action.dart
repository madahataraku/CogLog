part of 'trends_screen_view_model.dart';

/// 推移画面の操作。
@internal
extension TrendsScreenViewModelActions on TrendsScreenViewModel {
  /// 期間を選ぶ。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSelectPeriod(TrendsPeriod.days90);
  /// ```
  Future<void> onSelectPeriod(TrendsPeriod period) {
    return OnSelectPeriodDelegate(state: state).execute(period);
  }

  /// 指標グループを選ぶ。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSelectGroup(TrendsMetricGroup.body);
  /// ```
  Future<void> onSelectGroup(TrendsMetricGroup group) {
    return OnSelectGroupDelegate(state: state).execute(group);
  }
}
