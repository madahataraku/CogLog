/// チュートリアルの種類（メイン／文脈）。
///
/// Example:
/// ```dart
/// TutorialKind.main;
/// ```
enum TutorialKind {
  /// メイン導線（段階1〜4）。
  main,

  /// 撮影画面文脈（段階5）。
  camera,

  /// 撮影結果文脈（段階6）。
  meterEdit,

  /// 推移文脈（段階7）。
  trends,

  /// 運動履歴文脈（段階8）。
  history,

  /// アチーブメント文脈。
  achievement,
}
