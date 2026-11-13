import 'package:meta/meta.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

import '../strings.dart';

/// ホーム用の条件付きアドバイス catalog と指標ラベルを組み立てる。
///
/// Example:
/// ```dart
/// final catalog = buildTopConditionalAdviceCatalog();
/// final labels = buildTopConditionalAdviceMetricLabels();
/// ```
@internal
ConditionalAdviceCatalog buildTopConditionalAdviceCatalog() {
  return ConditionalAdviceCatalog(
    over300: [
      AdviceTemplate(
        text: strings.screen_feature_top_advice_over_300_1,
        tone: AdviceTone.realized,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_over_300_2,
        tone: AdviceTone.realized,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_over_300_3,
        tone: AdviceTone.realized,
      ),
    ],
    over200: [
      AdviceTemplate(
        text: strings.screen_feature_top_advice_over_200_1,
        tone: AdviceTone.happy,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_over_200_2,
        tone: AdviceTone.happy,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_over_200_3,
        tone: AdviceTone.happy,
      ),
    ],
    streakGoals: [
      AdviceTemplate(
        text: strings.screen_feature_top_advice_streak_goals_1,
        tone: AdviceTone.happy,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_streak_goals_2,
        tone: AdviceTone.happy,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_streak_goals_3,
        tone: AdviceTone.happy,
      ),
    ],
    allPerfect: [
      AdviceTemplate(
        text: strings.screen_feature_top_advice_all_perfect_1,
        tone: AdviceTone.happy,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_all_perfect_2,
        tone: AdviceTone.happy,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_all_perfect_3,
        tone: AdviceTone.happy,
      ),
    ],
    twoAchieved: [
      AdviceTemplate(
        text: strings.screen_feature_top_advice_two_achieved_1(
          metric: '{metric}',
        ),
        tone: AdviceTone.fun,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_two_achieved_2(
          metric: '{metric}',
        ),
        tone: AdviceTone.fun,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_two_achieved_3(
          metric: '{metric}',
        ),
        tone: AdviceTone.fun,
      ),
    ],
    oneAchieved: [
      AdviceTemplate(
        text: strings.screen_feature_top_advice_one_achieved_1(
          metric: '{metric}',
        ),
        tone: AdviceTone.fun,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_one_achieved_2(
          metric: '{metric}',
        ),
        tone: AdviceTone.fun,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_one_achieved_3(
          metric: '{metric}',
        ),
        tone: AdviceTone.fun,
      ),
    ],
    nearMissLow: [
      AdviceTemplate(
        text: strings.screen_feature_top_advice_near_miss_low_1(
          metric: '{metric}',
        ),
        tone: AdviceTone.realized,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_near_miss_low_2(
          metric: '{metric}',
        ),
        tone: AdviceTone.realized,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_near_miss_low_3(
          metric: '{metric}',
        ),
        tone: AdviceTone.realized,
      ),
    ],
    welcomeBack: [
      AdviceTemplate(
        text: strings.screen_feature_top_advice_welcome_back_1,
        tone: AdviceTone.fun,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_welcome_back_2,
        tone: AdviceTone.fun,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_welcome_back_3,
        tone: AdviceTone.fun,
      ),
    ],
    noPositiveGoal: [
      AdviceTemplate(
        text: strings.screen_feature_top_advice_no_positive_goal_1,
        tone: AdviceTone.realized,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_no_positive_goal_2,
        tone: AdviceTone.realized,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_no_positive_goal_3,
        tone: AdviceTone.realized,
      ),
    ],
  );
}

/// `{metric}` 置換に使う走行距離・カロリー・時間の表示名。
///
/// Example:
/// ```dart
/// buildTopConditionalAdviceMetricLabels()[ConditionalAdviceMetric.distance];
/// ```
@internal
Map<ConditionalAdviceMetric, String> buildTopConditionalAdviceMetricLabels() {
  return {
    ConditionalAdviceMetric.distance: strings.screen_feature_top_distance,
    ConditionalAdviceMetric.calories: strings.screen_feature_top_calories,
    ConditionalAdviceMetric.duration: strings.screen_feature_top_duration,
  };
}
