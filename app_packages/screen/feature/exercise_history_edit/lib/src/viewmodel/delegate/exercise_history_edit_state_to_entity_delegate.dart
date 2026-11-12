import 'package:meta/meta.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';

import '../../strings.dart';
import '../can_submit_exercise_history_edit.dart';
import '../entity/exercise_history_edit_screen_entity.dart';
import '../state/exercise_history_edit_screen_state.dart';

/// 編集 State を入力欄の表示文字列へ変える。
///
/// Example:
/// ```dart
/// const ExerciseHistoryEditStateToEntityDelegate().execute(
///   ExerciseHistoryEditScreenState.initial(id: 'id'),
/// );
/// ```
@internal
final class ExerciseHistoryEditStateToEntityDelegate {
  /// 変換を作る。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryEditStateToEntityDelegate();
  /// ```
  const ExerciseHistoryEditStateToEntityDelegate();

  /// [state] を文言付き Entity にする。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryEditStateToEntityDelegate().execute(
  ///   ExerciseHistoryEditScreenState.initial(id: 'id'),
  /// );
  /// ```
  ExerciseHistoryEditScreenEntity execute(
    ExerciseHistoryEditScreenState state,
  ) {
    if (state.loading) {
      return const ExerciseHistoryEditScreenEntity(
        showLoading: true,
        showMissing: false,
        showLoadError: false,
        canRetry: false,
        loadErrorText: null,
        distanceText: '',
        hoursText: '',
        minutesText: '',
        secondsText: '',
        averageSpeedText: '',
        caloriesText: '',
        recordedAt: null,
        showHandEntryGuidance: false,
        isDirty: false,
        busy: true,
        canSave: false,
        saveErrorText: null,
        permissionDeniedText: null,
        showOpenSettings: false,
        photoPath: null,
        showPhotoBytes: false,
        showPhotoPath: false,
        showPhotoError: false,
      );
    }
    if (state.missing) {
      return const ExerciseHistoryEditScreenEntity(
        showLoading: false,
        showMissing: true,
        showLoadError: false,
        canRetry: false,
        loadErrorText: null,
        distanceText: '',
        hoursText: '',
        minutesText: '',
        secondsText: '',
        averageSpeedText: '',
        caloriesText: '',
        recordedAt: null,
        showHandEntryGuidance: false,
        isDirty: false,
        busy: false,
        canSave: false,
        saveErrorText: null,
        permissionDeniedText: null,
        showOpenSettings: false,
        photoPath: null,
        showPhotoBytes: false,
        showPhotoPath: false,
        showPhotoError: false,
      );
    }
    if (state.loadError) {
      return ExerciseHistoryEditScreenEntity(
        showLoading: false,
        showMissing: false,
        showLoadError: true,
        canRetry: true,
        loadErrorText: strings.screen_feature_exercise_history_edit_load_failed,
        distanceText: '',
        hoursText: '',
        minutesText: '',
        secondsText: '',
        averageSpeedText: '',
        caloriesText: '',
        recordedAt: null,
        showHandEntryGuidance: false,
        isDirty: false,
        busy: false,
        canSave: false,
        saveErrorText: null,
        permissionDeniedText: null,
        showOpenSettings: false,
        photoPath: null,
        showPhotoBytes: false,
        showPhotoPath: false,
        showPhotoError: false,
      );
    }

    final duration = state.duration;
    final busy = state.reading || state.saving;
    final canSave =
        !busy &&
        !state.inputsInvalid &&
        canSubmitExerciseHistoryEdit(
          distanceKm: state.distanceKm,
          duration: state.duration,
          averageSpeedKmh: state.averageSpeedKmh,
          caloriesKcal: state.caloriesKcal,
          recordedAt: state.recordedAt,
          creationStartedAt: state.creationStartedAt,
          capturedAt: state.capturedAt,
        );
    final permissionText = switch (state.permissionDeniedKind) {
      MeterPhotoPermissionKind.camera =>
        strings.screen_feature_exercise_history_edit_permission_camera,
      MeterPhotoPermissionKind.library =>
        strings.screen_feature_exercise_history_edit_permission_library,
      null => null,
    };
    final hasBytes = state.photoBytes != null;
    final hasPath = state.photoPath != null;
    return ExerciseHistoryEditScreenEntity(
      showLoading: false,
      showMissing: false,
      showLoadError: false,
      canRetry: false,
      loadErrorText: null,
      distanceText: _optionalNumber(state.distanceKm),
      hoursText: duration == null ? '' : '${duration.inHours}',
      minutesText: duration == null
          ? ''
          : '${duration.inMinutes.remainder(60)}',
      secondsText: duration == null
          ? ''
          : '${duration.inSeconds.remainder(60)}',
      averageSpeedText: _optionalNumber(state.averageSpeedKmh),
      caloriesText: _optionalNumber(state.caloriesKcal),
      recordedAt: state.recordedAt,
      showHandEntryGuidance: state.showHandEntryGuidance,
      isDirty: state.dirty,
      busy: busy,
      canSave: canSave,
      saveErrorText: state.saveError
          ? strings.screen_feature_exercise_history_edit_save_failed
          : null,
      permissionDeniedText: permissionText,
      showOpenSettings: permissionText != null,
      photoPath: state.photoPath,
      showPhotoBytes: hasBytes,
      showPhotoPath: !hasBytes && hasPath,
      showPhotoError: !hasBytes && !hasPath,
    );
  }

  /// 未設定は空、設定済みは [toString] の結果。
  ///
  /// Example:
  /// ```dart
  /// _optionalNumber(1.5);
  /// ```
  String _optionalNumber(double? value) => value == null ? '' : '$value';
}
