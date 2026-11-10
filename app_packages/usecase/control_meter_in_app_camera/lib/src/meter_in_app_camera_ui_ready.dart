part of 'meter_in_app_camera_ui_status.dart';

/// プレビュー表示可能。
final class MeterInAppCameraUiReady extends MeterInAppCameraUiStatus {
  /// [aspectRatio] を持つ ready 状態を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterInAppCameraUiReady(aspectRatio: 0.75);
  /// ```
  const MeterInAppCameraUiReady({required this.aspectRatio});

  /// プレビューの縦横比。
  final double aspectRatio;
}
