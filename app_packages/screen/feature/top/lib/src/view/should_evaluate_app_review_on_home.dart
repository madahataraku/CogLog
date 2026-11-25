/// ホームでアプリ内レビュー評価を走らせてよいか。
///
/// Example:
/// ```dart
/// shouldEvaluateAppReviewOnHome(
///   homeTabSelected: true,
///   foreground: true,
///   tutorialShowing: false,
///   pendingTutorialMain: false,
///   pendingTutorialAchievement: false,
///   pendingModelDownloadGuidance: false,
///   pendingGemmaMeterGuidance: false,
///   homeRouteIsCurrent: true,
/// );
/// ```
bool shouldEvaluateAppReviewOnHome({
  required bool homeTabSelected,
  required bool foreground,
  required bool tutorialShowing,
  required bool pendingTutorialMain,
  required bool pendingTutorialAchievement,
  required bool pendingModelDownloadGuidance,
  required bool pendingGemmaMeterGuidance,
  required bool homeRouteIsCurrent,
}) {
  if (!homeTabSelected || !foreground) {
    return false;
  }
  if (tutorialShowing) {
    return false;
  }
  if (pendingTutorialMain || pendingTutorialAchievement) {
    return false;
  }
  if (pendingModelDownloadGuidance || pendingGemmaMeterGuidance) {
    return false;
  }
  if (!homeRouteIsCurrent) {
    return false;
  }
  return true;
}
