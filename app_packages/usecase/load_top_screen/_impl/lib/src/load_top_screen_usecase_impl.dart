import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_top_screen_metric/data_repository_top_screen_metric.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';

/// Repository からトップ画面の合計と目標を読む。
///
/// Example:
/// ```dart
/// LoadTopScreenUsecaseImpl(
///   histories: histories,
///   metrics: metrics,
///   goals: goals,
///   newIndicator: newIndicator,
/// ).execute(
///   LoadTopScreenRequest(now: DateTime(2026, 11, 5, 15)),
/// );
/// ```
final class LoadTopScreenUsecaseImpl implements LoadTopScreenUsecase {
  /// [histories]・[metrics]・[goals]・[newIndicator] を読む実装を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadTopScreenUsecaseImpl(
  ///   histories: histories,
  ///   metrics: metrics,
  ///   goals: goals,
  ///   newIndicator: newIndicator,
  /// );
  /// ```
  const LoadTopScreenUsecaseImpl({
    required this.histories,
    required this.metrics,
    required this.goals,
    required this.newIndicator,
  });

  /// 運動履歴の読み出し。
  final ExerciseHistoryRepository histories;

  /// 指標選択の読み出し。
  final TopScreenMetricRepository metrics;

  /// 一日あたり目標の読み出し。
  final DailyGoalRepository goals;

  /// 新規アチーブメント有無。
  final LoadAchievementNewIndicatorUsecase newIndicator;

  /// 保存済み指標が無ければ消費カロリーにする。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(LoadTopScreenRequest(now: DateTime(2026, 11, 5, 15)));
  /// ```
  @override
  Future<LoadTopScreenResult> execute(LoadTopScreenRequest request) async {
    final all = await histories.list();
    final metric = await metrics.read() ?? PeriodTotalMetric.calories;
    final goal = await goals.read();
    final now = request.now;
    final todayWindow = PeriodWindow.today(now);
    final todayHistories = [
      for (final history in all)
        if (todayWindow.contains(history.recordedAt)) history,
    ];
    final hasNew = await newIndicator.execute(now: request.now);
    return LoadTopScreenResult(
      metric: metric,
      today: PeriodAggregate.of(all, todayWindow),
      week: PeriodAggregate.of(all, PeriodWindow.week(now)),
      month: PeriodAggregate.of(all, PeriodWindow.month(now)),
      goal: goal,
      todayHistories: todayHistories,
      consecutiveExerciseDays: ConsecutiveExerciseDays.of(all, now),
      consecutiveGoalAchievementDays: ConsecutiveGoalAchievementDays.of(
        all,
        goal,
        now,
        null,
      ),
      daysSincePreviousExerciseDay: DaysSincePreviousExerciseDay.of(all, now),
      hasNewAchievements: hasNew,
    );
  }
}
