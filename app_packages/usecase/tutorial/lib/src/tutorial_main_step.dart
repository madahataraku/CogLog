/// メイン導線の段階（非永続。再開は常に homeIntro）。
///
/// Example:
/// ```dart
/// TutorialMainStep.homeIntro;
/// ```
enum TutorialMainStep {
  /// 段階1: ホーム紹介。
  homeIntro,

  /// 段階2: タブ概要。
  tabOverview,

  /// 段階3: 目標推奨。
  goalRecommend,

  /// 段階4: メーター記録推奨。
  meterRecommend,
}
