import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_top/src/view/top_conditional_advice_catalog.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

void main() {
  setUpAll(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDownAll(LocalizeStringDelegate.resetDelegateForTest);

  test('条件付き catalog の各 kind は 3 件でトーンが ID 表どおり', () {
    final catalog = buildTopConditionalAdviceCatalog();

    void expectKind(
      ConditionalAdviceKind kind,
      AdviceTone tone, {
      bool metricPlaceholder = false,
    }) {
      final templates = catalog.templatesFor(kind);
      expect(templates, hasLength(3));
      for (final template in templates) {
        expect(template.tone, tone);
        if (metricPlaceholder) {
          expect(template.text, contains('{metric}'));
        }
      }
    }

    expectKind(ConditionalAdviceKind.over300, AdviceTone.realized);
    expectKind(ConditionalAdviceKind.over200, AdviceTone.happy);
    expectKind(ConditionalAdviceKind.streakGoals, AdviceTone.happy);
    expectKind(ConditionalAdviceKind.allPerfect, AdviceTone.happy);
    expectKind(
      ConditionalAdviceKind.twoAchieved,
      AdviceTone.fun,
      metricPlaceholder: true,
    );
    expectKind(
      ConditionalAdviceKind.oneAchieved,
      AdviceTone.fun,
      metricPlaceholder: true,
    );
    expectKind(
      ConditionalAdviceKind.nearMissLow,
      AdviceTone.realized,
      metricPlaceholder: true,
    );
    expectKind(ConditionalAdviceKind.welcomeBack, AdviceTone.fun);
    expectKind(ConditionalAdviceKind.noPositiveGoal, AdviceTone.realized);
  });

  test('metricLabels は指標文言と一致する', () {
    final labels = buildTopConditionalAdviceMetricLabels();
    expect(labels[ConditionalAdviceMetric.distance], '走行距離');
    expect(labels[ConditionalAdviceMetric.calories], '消費カロリー');
    expect(labels[ConditionalAdviceMetric.duration], '運動時間');
  });
}
