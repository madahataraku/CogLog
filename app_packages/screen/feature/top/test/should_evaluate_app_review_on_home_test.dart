import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_top/src/view/should_evaluate_app_review_on_home.dart';

void main() {
  const base = (
    homeTabSelected: true,
    foreground: true,
    tutorialShowing: false,
    pendingTutorialMain: false,
    pendingTutorialAchievement: false,
    pendingModelDownloadGuidance: false,
    pendingGemmaMeterGuidance: false,
    homeRouteIsCurrent: true,
  );

  test('競合なしなら true', () {
    expect(
      shouldEvaluateAppReviewOnHome(
        homeTabSelected: base.homeTabSelected,
        foreground: base.foreground,
        tutorialShowing: base.tutorialShowing,
        pendingTutorialMain: base.pendingTutorialMain,
        pendingTutorialAchievement: base.pendingTutorialAchievement,
        pendingModelDownloadGuidance: base.pendingModelDownloadGuidance,
        pendingGemmaMeterGuidance: base.pendingGemmaMeterGuidance,
        homeRouteIsCurrent: base.homeRouteIsCurrent,
      ),
      isTrue,
    );
  });

  test('ホーム以外は false', () {
    expect(
      shouldEvaluateAppReviewOnHome(
        homeTabSelected: false,
        foreground: true,
        tutorialShowing: false,
        pendingTutorialMain: false,
        pendingTutorialAchievement: false,
        pendingModelDownloadGuidance: false,
        pendingGemmaMeterGuidance: false,
        homeRouteIsCurrent: true,
      ),
      isFalse,
    );
  });

  test('コーチマーク中は false', () {
    expect(
      shouldEvaluateAppReviewOnHome(
        homeTabSelected: true,
        foreground: true,
        tutorialShowing: true,
        pendingTutorialMain: false,
        pendingTutorialAchievement: false,
        pendingModelDownloadGuidance: false,
        pendingGemmaMeterGuidance: false,
        homeRouteIsCurrent: true,
      ),
      isFalse,
    );
  });

  test('誘導 pending は false', () {
    expect(
      shouldEvaluateAppReviewOnHome(
        homeTabSelected: true,
        foreground: true,
        tutorialShowing: false,
        pendingTutorialMain: false,
        pendingTutorialAchievement: false,
        pendingModelDownloadGuidance: true,
        pendingGemmaMeterGuidance: false,
        homeRouteIsCurrent: true,
      ),
      isFalse,
    );
  });

  test('ダイアログ上は false', () {
    expect(
      shouldEvaluateAppReviewOnHome(
        homeTabSelected: true,
        foreground: true,
        tutorialShowing: false,
        pendingTutorialMain: false,
        pendingTutorialAchievement: false,
        pendingModelDownloadGuidance: false,
        pendingGemmaMeterGuidance: false,
        homeRouteIsCurrent: false,
      ),
      isFalse,
    );
  });
}
