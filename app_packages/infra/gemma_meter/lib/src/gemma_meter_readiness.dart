/// Gemma E2B メーター経路の準備状態。
///
/// Example:
/// ```dart
/// GemmaMeterReadiness.ready;
/// ```
enum GemmaMeterReadiness {
  /// 直ちに画像付き生成できる。
  ready,

  /// モデル未ダウンロード。誘導 (B) の候補になり得る。
  modelNotDownloaded,

  /// 初期化不能など。誘導せず手打ち。
  unavailable,
}
