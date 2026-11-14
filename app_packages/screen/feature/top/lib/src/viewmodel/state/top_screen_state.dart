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
  /// 読み込み済みフラグ、指標、3 期間の合計、目標、アドバイス、誘導予約、新規有無を持つ。
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
    required this.pendingModelDownloadGuidance,
    required this.pendingGemmaMeterGuidance,
    required this.hasNewAchievements,
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
    pendingModelDownloadGuidance: false,
    pendingGemmaMeterGuidance: false,
    hasNewAchievements: false,
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

  /// OS LLM モデル未ダウンロード誘導 (A) を表示予約しているとき true。
  final bool pendingModelDownloadGuidance;

  /// Gemma メーター誘導 (B) を表示予約しているとき true。
  final bool pendingGemmaMeterGuidance;

  /// ホーム trophy に新規ドットを出すとき true。
  final bool hasNewAchievements;

  /// 指定した項目だけ差し替えた [TopScreenState] を返す。
  ///
  /// 未指定の項目は現在値を保つ。
  ///
  /// Example:
  /// ```dart
  /// state.copyWith(pendingGemmaMeterGuidance: true);
  /// ```
  TopScreenState copyWith({
    bool? loaded,
    PeriodTotalMetric? metric,
    PeriodAggregate? today,
    PeriodAggregate? week,
    PeriodAggregate? month,
    DailyGoal? goal,
    String? adviceText,
    AdviceTone? adviceTone,
    bool? pendingModelDownloadGuidance,
    bool? pendingGemmaMeterGuidance,
    bool? hasNewAchievements,
  }) {
    return TopScreenState(
      loaded: loaded ?? this.loaded,
      metric: metric ?? this.metric,
      today: today ?? this.today,
      week: week ?? this.week,
      month: month ?? this.month,
      goal: goal ?? this.goal,
      adviceText: adviceText ?? this.adviceText,
      adviceTone: adviceTone ?? this.adviceTone,
      pendingModelDownloadGuidance:
          pendingModelDownloadGuidance ?? this.pendingModelDownloadGuidance,
      pendingGemmaMeterGuidance:
          pendingGemmaMeterGuidance ?? this.pendingGemmaMeterGuidance,
      hasNewAchievements: hasNewAchievements ?? this.hasNewAchievements,
    );
  }
}
