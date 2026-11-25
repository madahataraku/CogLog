/// チュートリアルの種類（メイン／文脈）。
///
/// Example:
/// ```dart
/// TutorialKind.main;
/// ```
enum TutorialKind {
  /// メイン導線（段階1〜7）。
  main,

  /// 目標設定文脈（一日あたり／週間日数／自動更新）。
  goalSettings,

  /// 撮影画面文脈。
  camera,

  /// 撮影結果文脈。
  meterEdit,

  /// 推移文脈。
  trends,

  /// 運動履歴文脈。
  history,
}
