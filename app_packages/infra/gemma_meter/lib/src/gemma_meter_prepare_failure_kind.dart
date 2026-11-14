/// Gemma モデル準備の失敗種別。
///
/// Example:
/// ```dart
/// GemmaMeterPrepareFailureKind.wifiRequired;
/// ```
enum GemmaMeterPrepareFailureKind {
  /// Wi-Fi 以外のため準備を開始しなかった。
  wifiRequired,

  /// 端末の空き容量が足りない。
  insufficientStorage,

  /// 通信に失敗した。
  network,

  /// 上記以外の失敗。
  generic,
}
