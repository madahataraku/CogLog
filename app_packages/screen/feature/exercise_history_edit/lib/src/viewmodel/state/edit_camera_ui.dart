import 'package:meta/meta.dart';

/// 編集画面のアプリ内カメラ UI 状態。
///
/// Example:
/// ```dart
/// EditCameraUi.idle;
/// ```
@internal
enum EditCameraUi {
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
