import '../entity/data_management_screen_entity.dart';
import '../state/data_management_screen_state.dart';

/// State を Entity へ写す。
///
/// Example:
/// ```dart
/// const DataManagementStateToEntityDelegate().convert(
///   DataManagementScreenState.initial,
/// );
/// ```
final class DataManagementStateToEntityDelegate {
  /// 変換器を作る。
  ///
  /// Example:
  /// ```dart
  /// const DataManagementStateToEntityDelegate();
  /// ```
  const DataManagementStateToEntityDelegate();

  /// [state] を表示用にする。
  ///
  /// Example:
  /// ```dart
  /// delegate.convert(DataManagementScreenState.initial);
  /// ```
  DataManagementScreenEntity convert(DataManagementScreenState state) {
    final showProgress =
        state.phase == DataManagementPhase.exporting ||
        state.phase == DataManagementPhase.importing;
    return DataManagementScreenEntity(
      interactive: !state.isBusy,
      showProgress: showProgress,
      progressFraction: state.progressFraction,
      phase: state.phase,
      errorKind: state.errorKind,
      photoMissingCount: state.photoMissingCount,
      notificationPermissionDenied: state.notificationPermissionDenied,
      awaitingImportConfirm: state.phase == DataManagementPhase.confirming,
    );
  }
}
