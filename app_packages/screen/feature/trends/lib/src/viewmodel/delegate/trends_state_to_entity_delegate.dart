import '../entity/trends_screen_entity.dart';
import '../entity/trends_visible_series.dart';
import '../state/trends_comparison.dart';
import '../state/trends_health_permission_ui.dart';
import '../state/trends_screen_state.dart';

/// State を表示用 Entity へ写す。
///
/// Example:
/// ```dart
/// const TrendsStateToEntityDelegate().execute(TrendsScreenState.initial);
/// ```
final class TrendsStateToEntityDelegate {
  /// 変換だけを行う。
  ///
  /// Example:
  /// ```dart
  /// const TrendsStateToEntityDelegate();
  /// ```
  const TrendsStateToEntityDelegate();

  /// [state] の選択・系列・許可フラグを Entity にする。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(TrendsScreenState.initial);
  /// ```
  TrendsScreenEntity execute(TrendsScreenState state) {
    final visible = <TrendsVisibleSeries>[];
    for (final kind in state.comparison.metrics) {
      final series = state.exerciseSeries[kind] ?? state.bodySeries[kind];
      if (series != null) {
        visible.add(series);
      }
    }
    final includesBody = state.comparison.includesBody;
    final permanentlyDenied =
        state.healthPermissionUi == TrendsHealthPermissionUi.permanentlyDenied;
    final granted =
        state.healthPermissionUi == TrendsHealthPermissionUi.granted;
    // リクエスト後も granted でない（iOS unknown / Android 全拒否）ときは
    // 許可ボタンを隠し、OS 設定へ誘導する。部分許可は再リクエストを残す。
    final showRequestPermissionButton =
        includesBody &&
        !permanentlyDenied &&
        (state.bodyPermissionIncomplete ||
            (!granted && !state.healthPermissionRequested));
    final showOpenSettingsButton =
        includesBody &&
        (permanentlyDenied ||
            (state.healthPermissionRequested &&
                !granted &&
                !state.bodyPermissionIncomplete));
    return TrendsScreenEntity(
      period: state.period,
      comparison: state.comparison,
      loading: state.loading,
      showRequestPermissionButton: showRequestPermissionButton,
      showRequestHistoryButton:
          includesBody && state.bodyHistoryLimited && granted,
      showOpenSettingsButton: showOpenSettingsButton,
      showRetryButton: state.bodyReadFailed,
      visibleSeries: visible,
      bucketCount: state.buckets.length,
    );
  }
}
