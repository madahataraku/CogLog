part 'meter_in_app_camera_failed.dart';
part 'meter_in_app_camera_idle.dart';
part 'meter_in_app_camera_permission_denied.dart';
part 'meter_in_app_camera_ready.dart';
part 'meter_in_app_camera_starting.dart';

/// アプリ内カメラの公開状態。
///
/// Example:
/// ```dart
/// const MeterInAppCameraIdle();
/// ```
sealed class MeterInAppCameraStatus {
  /// 状態の基底を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterInAppCameraIdle();
  /// ```
  const MeterInAppCameraStatus();
}
