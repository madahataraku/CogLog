/// 推移画面が扱うヘルス許可の表示用状態。
///
/// usecase の許可結果を写したもの。Widget はこれだけを見る。
///
/// Example:
/// ```dart
/// TrendsHealthPermissionUi.denied;
/// ```
enum TrendsHealthPermissionUi {
  /// まだ判定できない。
  unknown,

  /// 読取が許可されている。
  granted,

  /// 拒否されたが再リクエストできる。
  denied,

  /// OS 設定からしか許可できない。
  permanentlyDenied,
}
