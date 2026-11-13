import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

import 'package:usecase_generate_top_advice_impl/usecase_generate_top_advice_impl.dart';

DailyGoal tripleGoal({
  double distanceKm = 10,
  double caloriesKcal = 100,
  Duration duration = const Duration(minutes: 30),
}) => DailyGoal(
  distanceKm: distanceKm,
  caloriesKcal: caloriesKcal,
  duration: duration,
);

PeriodAggregate today({
  double distanceKm = 0,
  double caloriesKcal = 0,
  Duration duration = Duration.zero,
}) => PeriodAggregate(
  count: 1,
  distanceKm: distanceKm,
  caloriesKcal: caloriesKcal,
  duration: duration,
);

ConditionalAdviceSelection? select({
  required DailyGoal goal,
  required PeriodAggregate aggregate,
  int consecutiveGoalAchievementDays = 0,
  int? daysSincePreviousExerciseDay,
}) {
  final achievement = GoalAchievement.of(goal, aggregate);
  return ConditionalAdviceSelector.select(
    achievement: achievement,
    goal: goal,
    consecutiveGoalAchievementDays: consecutiveGoalAchievementDays,
    daysSincePreviousExerciseDay: daysSincePreviousExerciseDay,
  );
}

void main() {
  group('over300', () {
    test('いずれかが 300% 超', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(distanceKm: 31),
      );
      expect(result?.kind, ConditionalAdviceKind.over300);
      expect(result?.metric, isNull);
    });

    test('over300 は welcomeBack より優先', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(distanceKm: 31),
        daysSincePreviousExerciseDay: 7,
      );
      expect(result?.kind, ConditionalAdviceKind.over300);
    });
  });

  group('over200', () {
    test('200% 超 300% 以下', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(caloriesKcal: 250),
      );
      expect(result?.kind, ConditionalAdviceKind.over200);
    });

    test('300% ちょうどは over200', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(caloriesKcal: 300),
      );
      expect(result?.kind, ConditionalAdviceKind.over200);
    });

    test('300% 超では over200 にならない', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(caloriesKcal: 301),
      );
      expect(result?.kind, ConditionalAdviceKind.over300);
    });
  });

  group('allPerfect と 200% 境界', () {
    test('200% ちょうどは allPerfect', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(
          distanceKm: 20,
          caloriesKcal: 200,
          duration: const Duration(minutes: 60),
        ),
      );
      expect(result?.kind, ConditionalAdviceKind.allPerfect);
    });

    test('200% 超は over200 で allPerfect ではない', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(
          distanceKm: 20,
          caloriesKcal: 201,
          duration: const Duration(minutes: 60),
        ),
      );
      expect(result?.kind, ConditionalAdviceKind.over200);
    });
  });

  group('streakGoals', () {
    test('連続 1 日は非該当', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(
          distanceKm: 10,
          caloriesKcal: 100,
          duration: const Duration(minutes: 30),
        ),
        consecutiveGoalAchievementDays: 1,
      );
      expect(result?.kind, ConditionalAdviceKind.allPerfect);
    });

    test('連続 2 日以上', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(
          distanceKm: 10,
          caloriesKcal: 100,
          duration: const Duration(minutes: 30),
        ),
        consecutiveGoalAchievementDays: 2,
      );
      expect(result?.kind, ConditionalAdviceKind.streakGoals);
    });
  });

  group('twoAchieved / oneAchieved', () {
    test('正目標 3・達成 2', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(
          distanceKm: 10,
          caloriesKcal: 50,
          duration: const Duration(minutes: 30),
        ),
      );
      expect(result?.kind, ConditionalAdviceKind.twoAchieved);
      expect(result?.metric, ConditionalAdviceMetric.calories);
    });

    test('未達があと一歩でも twoAchieved', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(
          distanceKm: 10,
          caloriesKcal: 85,
          duration: const Duration(minutes: 30),
        ),
      );
      expect(result?.kind, ConditionalAdviceKind.twoAchieved);
      expect(result?.metric, ConditionalAdviceMetric.calories);
    });

    test('正目標 3・達成 1', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(
          distanceKm: 10,
          caloriesKcal: 50,
          duration: const Duration(minutes: 15),
        ),
      );
      expect(result?.kind, ConditionalAdviceKind.oneAchieved);
      expect(result?.metric, ConditionalAdviceMetric.distance);
    });

    test('正目標 1〜2 では one/two 非該当', () {
      final twoGoals = DailyGoal(distanceKm: 10, caloriesKcal: 100);
      final result = select(
        goal: twoGoals,
        aggregate: today(distanceKm: 10, caloriesKcal: 50),
      );
      expect(
        result?.kind,
        isNot(
          anyOf(
            ConditionalAdviceKind.oneAchieved,
            ConditionalAdviceKind.twoAchieved,
          ),
        ),
      );
    });
  });

  group('nearMissLow', () {
    test('80% ちょうどで該当', () {
      final result = select(
        goal: DailyGoal(distanceKm: 10, caloriesKcal: 100),
        aggregate: today(distanceKm: 8, caloriesKcal: 100),
      );
      expect(result?.kind, ConditionalAdviceKind.nearMissLow);
      expect(result?.metric, ConditionalAdviceMetric.distance);
    });

    test('79.9% はあと一歩ではない', () {
      final result = select(
        goal: DailyGoal(distanceKm: 10, caloriesKcal: 100),
        aggregate: today(distanceKm: 7.99, caloriesKcal: 100),
      );
      expect(result?.kind, isNot(ConditionalAdviceKind.nearMissLow));
      expect(result, isNull);
    });

    test('他に未達があれば nearMiss 不可', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(
          distanceKm: 8,
          caloriesKcal: 50,
          duration: const Duration(minutes: 30),
        ),
      );
      expect(result?.kind, isNot(ConditionalAdviceKind.nearMissLow));
    });
  });

  group('welcomeBack / noPositiveGoal', () {
    test('差 7 で候補', () {
      final result = select(
        goal: DailyGoal.unset,
        aggregate: today(distanceKm: 1),
        daysSincePreviousExerciseDay: 7,
      );
      expect(result?.kind, ConditionalAdviceKind.welcomeBack);
    });

    test('差 6 は非該当', () {
      final result = select(
        goal: DailyGoal.unset,
        aggregate: today(distanceKm: 1),
        daysSincePreviousExerciseDay: 6,
      );
      expect(result?.kind, ConditionalAdviceKind.noPositiveGoal);
    });

    test('直前無しは welcomeBack 非該当', () {
      final result = select(
        goal: DailyGoal.unset,
        aggregate: today(distanceKm: 1),
        daysSincePreviousExerciseDay: null,
      );
      expect(result?.kind, ConditionalAdviceKind.noPositiveGoal);
    });

    test('空白かつ正目標なしは welcomeBack が優先', () {
      final result = select(
        goal: DailyGoal.unset,
        aggregate: today(distanceKm: 2),
        daysSincePreviousExerciseDay: 10,
      );
      expect(result?.kind, ConditionalAdviceKind.welcomeBack);
    });

    test('正目標 0', () {
      final result = select(
        goal: const DailyGoal(
          distanceKm: 0,
          caloriesKcal: 0,
          duration: Duration.zero,
        ),
        aggregate: today(distanceKm: 1),
      );
      expect(result?.kind, ConditionalAdviceKind.noPositiveGoal);
    });
  });

  group('metric 優先順', () {
    test('twoAchieved の未達が距離のとき distance を埋め込む', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(
          distanceKm: 8,
          caloriesKcal: 100,
          duration: const Duration(minutes: 30),
        ),
      );
      expect(result?.kind, ConditionalAdviceKind.twoAchieved);
      expect(result?.metric, ConditionalAdviceMetric.distance);
    });

    test('距離よりカロリーが未達のとき calories を埋め込む', () {
      final result = select(
        goal: tripleGoal(),
        aggregate: today(
          distanceKm: 10,
          caloriesKcal: 85,
          duration: const Duration(minutes: 30),
        ),
      );
      expect(result?.kind, ConditionalAdviceKind.twoAchieved);
      expect(result?.metric, ConditionalAdviceMetric.calories);
    });
  });

  group('非該当', () {
    test('どの条件にも当てはまらなければ null', () {
      final result = select(
        goal: DailyGoal(distanceKm: 10),
        aggregate: today(distanceKm: 5),
      );
      expect(result, isNull);
    });
  });
}
