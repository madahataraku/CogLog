import 'package:domain_exercise_history/domain_exercise_history.dart';

import '../../strings.dart';
import '../entity/exercise_history_detail_screen_entity.dart';
import '../state/exercise_history_detail_screen_state.dart';

/// 詳細 State を表示用 Entity へ変える。
///
/// Example:
/// ```dart
/// const ExerciseHistoryDetailStateToEntityDelegate().execute(
///   ExerciseHistoryDetailScreenState.initial(id: 'id'),
/// );
/// ```
final class ExerciseHistoryDetailStateToEntityDelegate {
  /// 変換を作る。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryDetailStateToEntityDelegate();
  /// ```
  const ExerciseHistoryDetailStateToEntityDelegate();

  /// [state] を文言付き Entity にする。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryDetailStateToEntityDelegate().execute(
  ///   ExerciseHistoryDetailScreenState.initial(id: 'id'),
  /// );
  /// ```
  ExerciseHistoryDetailScreenEntity execute(
    ExerciseHistoryDetailScreenState state,
  ) {
    final showPagePosition = state.sameDayIds.length > 1;
    final pageCurrent = state.pageIndex + 1;
    final pageTotal = state.sameDayIds.length;
    final pageLoading = state.pageLoading;
    final actionErrorText = state.actionError
        ? strings.screen_feature_exercise_history_detail_delete_failed
        : null;

    ExerciseHistoryDetailScreenEntity empty({
      required bool showLoading,
      required bool showMissing,
      required bool showError,
      required bool canRetry,
      required String? errorText,
    }) => ExerciseHistoryDetailScreenEntity(
      showLoading: showLoading,
      showMissing: showMissing,
      showError: showError,
      canRetry: canRetry,
      errorText: errorText,
      showPagePosition: showPagePosition,
      pageCurrent: pageCurrent,
      pageTotal: pageTotal,
      pageLoading: pageLoading,
      showHeaderActions: false,
      headerActionsEnabled: false,
      actionErrorText: actionErrorText,
      caloriesText: '',
      durationText: '',
      distanceText: '',
      createdAtText: '',
      capturedAtText: '',
      averageSpeedText: '',
      recordedAtText: '',
      recordedAtEditedSuffix: '',
      savedAtText: '',
      photoPath: null,
      showPhoto: false,
      showPhotoError: false,
    );

    final history = state.history;
    if (state.loading && history == null && state.error == null) {
      return empty(
        showLoading: true,
        showMissing: false,
        showError: false,
        canRetry: false,
        errorText: null,
      );
    }
    if (state.missing) {
      return empty(
        showLoading: false,
        showMissing: true,
        showError: false,
        canRetry: false,
        errorText: null,
      );
    }
    if (state.error != null && history == null) {
      return empty(
        showLoading: false,
        showMissing: false,
        showError: true,
        canRetry: true,
        errorText: strings.screen_feature_exercise_history_detail_error,
      );
    }
    if (history == null) {
      return empty(
        showLoading: false,
        showMissing: false,
        showError: false,
        canRetry: false,
        errorText: null,
      );
    }
    final path = state.photoAbsolutePath;
    return ExerciseHistoryDetailScreenEntity(
      showLoading: false,
      showMissing: false,
      showError: false,
      canRetry: false,
      errorText: null,
      showPagePosition: showPagePosition,
      pageCurrent: pageCurrent,
      pageTotal: pageTotal,
      pageLoading: pageLoading,
      showHeaderActions: true,
      headerActionsEnabled: !state.deleting && !state.editing,
      actionErrorText: actionErrorText,
      caloriesText:
          '${PeriodTotalText.oneDecimal(history.caloriesKcal)} '
          '${strings.screen_feature_exercise_history_detail_calories_unit}',
      durationText: PeriodTotalText.duration(history.duration),
      distanceText:
          '${PeriodTotalText.oneDecimal(history.distanceKm)} '
          '${strings.screen_feature_exercise_history_detail_distance_unit}',
      createdAtText: formatLocalDateTime(history.creationStartedAt),
      capturedAtText: formatLocalDateTime(history.capturedAt),
      averageSpeedText:
          '${PeriodTotalText.oneDecimal(history.averageSpeedKmh)} '
          '${strings.screen_feature_exercise_history_detail_average_speed_unit}',
      recordedAtText: formatLocalDateTime(history.recordedAt),
      recordedAtEditedSuffix: history.recordedAtManuallySet
          ? strings.screen_feature_exercise_history_detail_edited
          : '',
      savedAtText: formatLocalDateTime(history.savedAt),
      photoPath: path,
      showPhoto: path != null,
      showPhotoError: path == null,
    );
  }
}

/// 端末ローカルの `yyyy-MM-dd HH:mm` にする。
///
/// Example:
/// ```dart
/// formatLocalDateTime(DateTime.utc(2026, 11, 5, 3));
/// ```
String formatLocalDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
