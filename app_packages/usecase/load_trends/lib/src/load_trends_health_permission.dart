/// 推移読み込み結果に載せるヘルス許可状態。
///
/// infra の許可状態から写す。画面はさらに UI 用 enum へ写す。
///
/// Example:
/// ```dart
/// LoadTrendsHealthPermission.granted;
/// ```
enum LoadTrendsHealthPermission {
  /// まだ判定できない。
  unknown,

  /// 読取が許可されている。
  granted,

  /// 拒否されたが再リクエストできる。
  denied,

  /// OS 設定からしか許可できない。
  permanentlyDenied,
}
