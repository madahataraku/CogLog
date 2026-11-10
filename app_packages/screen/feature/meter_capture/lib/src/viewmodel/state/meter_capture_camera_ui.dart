/// メーター記録カメラ画面の UI 状態。
///
/// Example:
/// ```dart
/// MeterCaptureCameraUi.idle;
/// ```
enum MeterCaptureCameraUi {
  /// 未開始。
  idle,

  /// 初期化中。
  starting,

  /// プレビュー可能。
  ready,

  /// カメラ権限拒否。
  permissionDenied,

  /// 初期化失敗。
  failed,
}
