/// 身体指標のヘルス許可状態。
///
/// Example:
/// ```dart
/// HealthBodyPermissionStatus.granted;
/// ```
enum HealthBodyPermissionStatus {
  /// まだ判定できない、または未リクエスト。
  unknown,

  /// 読取が許可されている。
  granted,

  /// 拒否されたが再リクエストできる。
  denied,

  /// OS 設定からしか許可できない。
  permanentlyDenied,
}
