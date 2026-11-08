import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

/// トップ画面が持つ期間合計・目標・アドバイス本文とトーン。
///
/// [loaded] が false のあいだは、指標の選択を受け付けない。
///
/// Example:
/// ```dart
/// TopScreenState.initial;
/// ```
final class TopScreenState {
  /// 読み込み済みフラグ、指標、3 期間の合計、目標、アドバイス本文とトーンを持つ。
  ///
  /// Example:
  /// ```dart
  /// TopScreenState.initial;
  /// ```
  const TopScreenState({
    required this.loaded,
    required this.metric,
    required this.today,
    required this.week,
    required this.month,
    required this.goal,
    required this.adviceText,
    required this.adviceTone,
  });

  /// まだ読み込んでいない状態。指標は消費カロリー。
  static const initial = TopScreenState(
    loaded: false,
    metric: PeriodTotalMetric.calories,
    today: PeriodAggregate.empty,
    week: PeriodAggregate.empty,
    month: PeriodAggregate.empty,
    goal: DailyGoal.unset,
    adviceText: '',
    adviceTone: AdviceTone.fun,
  );

  /// 読み込みが成功したあとに true。
  final bool loaded;

  /// 3 期間で共有する指標。
  final PeriodTotalMetric metric;

  /// 本日の合計。
  final PeriodAggregate today;

  /// 今週の合計。
  final PeriodAggregate week;

  /// 今月の合計。
  final PeriodAggregate month;

  /// 一日あたり目標。
  final DailyGoal goal;

  /// ワンポイントアドバイス本文。
  final String adviceText;

  /// ワンポイントアドバイスのトーン。
  final AdviceTone adviceTone;
}
