part of 'meter_in_app_camera_status.dart';

/// プレビュー表示可能。
final class MeterInAppCameraReady extends MeterInAppCameraStatus {
  /// [aspectRatio] を持つ ready 状態を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterInAppCameraReady(aspectRatio: 0.75);
  /// ```
  const MeterInAppCameraReady({required this.aspectRatio});

  /// プレビューの縦横比。
  final double aspectRatio;
}
