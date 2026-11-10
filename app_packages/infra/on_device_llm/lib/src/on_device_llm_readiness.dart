/// 端末上 LLM の準備状態。
///
/// Example:
/// ```dart
/// OnDeviceLlmReadiness.ready;
/// ```
enum OnDeviceLlmReadiness {
  /// 直ちに生成できる。
  ready,

  /// モデル未ダウンロード等で、誘導 UI の対象になり得る。
  modelNotDownloaded,

  /// 非対応など、誘導せず業務フォールバックする。
  unavailable,
}
