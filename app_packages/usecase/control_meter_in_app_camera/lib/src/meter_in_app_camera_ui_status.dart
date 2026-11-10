part 'meter_in_app_camera_ui_failed.dart';
part 'meter_in_app_camera_ui_idle.dart';
part 'meter_in_app_camera_ui_permission_denied.dart';
part 'meter_in_app_camera_ui_ready.dart';
part 'meter_in_app_camera_ui_starting.dart';

/// 画面が扱うアプリ内カメラ状態。
///
/// Example:
/// ```dart
/// const MeterInAppCameraUiIdle();
/// ```
sealed class MeterInAppCameraUiStatus {
  /// 状態の基底を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterInAppCameraUiIdle();
  /// ```
  const MeterInAppCameraUiStatus();
}
