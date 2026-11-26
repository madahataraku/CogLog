/// メイン導線の主ボタン後に View が行う遷移先。
///
/// Example:
/// ```dart
/// AdvanceTutorialMainNavigation.goalSettingsTab;
/// ```
enum AdvanceTutorialMainNavigation {
  /// 遷移しない（ホーム上の段階連鎖など）。
  none,

  /// 目標設定タブ（段階3）。
  goalSettingsTab,

  /// メーター記録タブ（段階4）。
  meterCaptureTab,

  /// 推移タブ（段階5）。
  trendsTab,

  /// 運動履歴タブ（段階6）。
  exerciseHistoryTab,

  /// アチーブメント画面（段階7）。
  achievements,
}
