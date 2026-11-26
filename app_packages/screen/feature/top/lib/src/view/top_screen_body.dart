import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

import '../strings.dart';
import '../viewmodel/entity/top_goal_ring_entity.dart';
import '../viewmodel/top_screen_view_model.dart';
import 'advice_speech_panel.dart';
import 'goal_achievement_ring.dart';
import 'top_screen_providers.dart';
import 'weekly_goal_achievement_bar.dart';

/// 期間の合計と指標の切り替え、吹き出し付きアドバイス、目標達成率。
///
/// Example:
/// ```dart
/// const TopScreenBody();
/// ```
@internal
class TopScreenBody extends HookConsumerWidget {
  /// 指標タブ・期間合計・アドバイス・達成リングをまとめた本文。
  ///
  /// Example:
  /// ```dart
  /// const TopScreenBody();
  /// ```
  const TopScreenBody({super.key});

  /// 指標タブと 3 期間、[AdviceSpeechPanel]、達成率リングと週間ゲージを縦に並べる。
  ///
  /// トロフィーに未確認実績があるときはバッジを重ねる。
  /// 指標切替の保存失敗時はタブ選択を変えず、ローカルの保存中フラグだけ戻す。
  ///
  /// Example:
  /// ```dart
  /// const TopScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(TopScreenProviders.entity);
    final saving = useState(false);
    final titleStyle = context.theme.typography.body.sm.copyWith(
      fontWeight: FontWeight.w600,
    );
    final viewModel = ref.watch(TopScreenViewModel.provider);

    final weeklyDays = entity.weeklyAchievementDays;
    final n = entity.weekGoalAchievementDayCount;
    final m = weeklyDays;
    final showGuidance = entity.showWeeklyGoalGuidance;
    final String ratioText;
    final String statusText;
    final String semanticsLabel;
    if (showGuidance || m == null) {
      ratioText = '';
      statusText = '';
      semanticsLabel = '';
    } else if (n < m) {
      ratioText = strings.screen_feature_top_weekly_achievement_ratio(
        n: '$n',
        m: '$m',
      );
      statusText = strings.screen_feature_top_weekly_achievement_remaining(
        x: '${m - n}',
      );
      semanticsLabel = strings.screen_feature_top_weekly_achievement_semantics(
        n: '$n',
        m: '$m',
        remaining: '${m - n}',
      );
    } else {
      ratioText = strings.screen_feature_top_weekly_achievement_ratio(
        n: '$n',
        m: '$m',
      );
      statusText = strings.screen_feature_top_weekly_achievement_done;
      semanticsLabel = strings
          .screen_feature_top_weekly_achievement_semantics_done(
            n: '$n',
            m: '$m',
          );
    }

    return FScaffold(
      header: FHeader(
        title: Text(strings.foundation_resources_app_name),
        suffixes: [
          CoachMarkTarget(
            id: CoachMarkTargetId.homeAchievementTrophy,
            child: FHeaderAction(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(FLucideIcons.trophy),
                  if (entity.hasNewAchievements)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Semantics(
                        label: strings
                            .screen_feature_top_achievements_new_semantics,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.theme.colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(width: 8, height: 8),
                        ),
                      ),
                    ),
                ],
              ),
              onPress: viewModel.onOpenAchievements,
              semanticsLabel: strings.screen_feature_top_achievements_semantics,
            ),
          ),
          FHeaderAction(
            icon: const Icon(FLucideIcons.settings),
            onPress: viewModel.onOpenAppSettings,
            semanticsLabel: strings.screen_feature_top_settings_semantics,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            CoachMarkTarget(
              id: CoachMarkTargetId.homeMetricSelect,
              child: FCard(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      FTabs(
                        control: .lifted(
                          index: PeriodTotalMetric.values.indexOf(
                            entity.metric,
                          ),
                          onChange: (index) async {
                            final metric = PeriodTotalMetric.values[index];
                            if (metric == entity.metric || saving.value) {
                              return;
                            }
                            saving.value = true;
                            try {
                              await ref
                                  .read(TopScreenViewModel.provider)
                                  .onSelectMetric(metric);
                            } on Object {
                              // 保存に失敗したときは State を変えない。未処理のエラーにしない。
                            } finally {
                              saving.value = false;
                            }
                          },
                        ),
                        children: [
                          for (final metric in PeriodTotalMetric.values)
                            FTabEntry(
                              label: Text(_metricLabel(metric)),
                              child: const SizedBox.shrink(),
                            ),
                        ],
                      ),
                      CoachMarkTarget(
                        id: CoachMarkTargetId.homePeriodTotals,
                        child: _PeriodTotalsRow(
                          todayLabel: strings.screen_feature_top_today,
                          weekLabel: strings.screen_feature_top_this_week,
                          monthLabel: strings.screen_feature_top_this_month,
                          todayValue: entity.todayText,
                          weekValue: entity.weekText,
                          monthValue: entity.monthText,
                          metric: entity.metric,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (entity.adviceText.isNotEmpty)
              AdviceSpeechPanel(
                adviceText: entity.adviceText,
                tone: entity.adviceTone,
                semanticsLabel: strings.screen_feature_top_advisor_semantics,
              ),
            FCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    Text(
                      strings.screen_feature_top_achievement_title,
                      style: titleStyle,
                    ),
                    CoachMarkTarget(
                      id: CoachMarkTargetId.homeGoalRings,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Expanded(
                            child: _ring(
                              title: strings.screen_feature_top_duration,
                              ring: entity.duration,
                            ),
                          ),
                          Expanded(
                            child: _ring(
                              title: strings.screen_feature_top_calories,
                              ring: entity.calories,
                            ),
                          ),
                          Expanded(
                            child: _ring(
                              title: strings.screen_feature_top_distance,
                              ring: entity.distance,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: WeeklyGoalAchievementBar(
                          title: strings
                              .screen_feature_top_weekly_achievement_title,
                          showGuidance: showGuidance,
                          guidanceText: strings
                              .screen_feature_top_weekly_achievement_guidance,
                          ratioText: ratioText,
                          statusText: statusText,
                          progress: entity.weeklyProgress,
                          semanticsLabel: semanticsLabel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [ring] を [GoalAchievementRing] に載せる。
///
/// Example:
/// ```dart
/// _ring(title: '運動時間', ring: entity.duration);
/// ```
Widget _ring({required String title, required TopGoalRingEntity ring}) {
  return GoalAchievementRing(
    title: title,
    lap1: ring.lap1,
    lap2: ring.lap2,
    percentText: ring.percentText,
    actualText: ring.actualText,
    goalText: ring.goalText,
    actualLabel: strings.screen_feature_top_actual_label,
    goalLabel: strings.screen_feature_top_goal_label,
    unsetPrompt: ring.isUnset ? strings.screen_feature_top_unset_prompt : null,
  );
}

/// 指標タブに出す [metric] のラベル文言。
///
/// Example:
/// ```dart
/// _metricLabel(PeriodTotalMetric.calories);
/// ```
String _metricLabel(PeriodTotalMetric metric) => switch (metric) {
  PeriodTotalMetric.distance => strings.screen_feature_top_distance,
  PeriodTotalMetric.calories => strings.screen_feature_top_calories,
  PeriodTotalMetric.duration => strings.screen_feature_top_duration,
};

/// [metric] の単位。運動時間は数値の中に単位を含むので null。
///
/// Example:
/// ```dart
/// _unit(PeriodTotalMetric.distance);
/// ```
String? _unit(PeriodTotalMetric metric) => switch (metric) {
  PeriodTotalMetric.distance => strings.screen_feature_top_distance_unit,
  PeriodTotalMetric.calories => strings.screen_feature_top_calories_unit,
  PeriodTotalMetric.duration => null,
};

/// 本日・今週・今月の期間合計を横並びで示す。
class _PeriodTotalsRow extends StatelessWidget {
  /// 3 期間の [_PeriodBox] を等幅で並べる。
  ///
  /// Example:
  /// ```dart
  /// _PeriodTotalsRow(
  ///   todayLabel: '本日',
  ///   weekLabel: '今週',
  ///   monthLabel: '今月',
  ///   todayValue: '--',
  ///   weekValue: '--',
  ///   monthValue: '--',
  ///   metric: PeriodTotalMetric.calories,
  /// );
  /// ```
  const _PeriodTotalsRow({
    required this.todayLabel,
    required this.weekLabel,
    required this.monthLabel,
    required this.todayValue,
    required this.weekValue,
    required this.monthValue,
    required this.metric,
  });

  /// 本日の期間名。
  final String todayLabel;

  /// 今週の期間名。
  final String weekLabel;

  /// 今月の期間名。
  final String monthLabel;

  /// 本日の合計表記。
  final String todayValue;

  /// 今週の合計表記。
  final String weekValue;

  /// 今月の合計表記。
  final String monthValue;

  /// 単位を決める指標。
  final PeriodTotalMetric metric;

  /// 本日・今週・今月を左から並べる。
  ///
  /// Example:
  /// ```dart
  /// _PeriodTotalsRow(
  ///   todayLabel: '本日',
  ///   weekLabel: '今週',
  ///   monthLabel: '今月',
  ///   todayValue: '--',
  ///   weekValue: '--',
  ///   monthValue: '--',
  ///   metric: PeriodTotalMetric.calories,
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: _PeriodBox(
            label: todayLabel,
            value: todayValue,
            metric: metric,
          ),
        ),
        Expanded(
          child: _PeriodBox(label: weekLabel, value: weekValue, metric: metric),
        ),
        Expanded(
          child: _PeriodBox(
            label: monthLabel,
            value: monthValue,
            metric: metric,
          ),
        ),
      ],
    );
  }
}

/// 1 期間の合計を、左上の期間名と中央の数字で示す。
class _PeriodBox extends StatelessWidget {
  /// [label] を左上に、[value] を中央に置く。
  ///
  /// Example:
  /// ```dart
  /// _PeriodBox(
  ///   label: '本日',
  ///   value: '--',
  ///   metric: PeriodTotalMetric.calories,
  /// );
  /// ```
  const _PeriodBox({
    required this.label,
    required this.value,
    required this.metric,
  });

  /// 左上に出す期間名。
  final String label;

  /// 中央に出す合計の表記。
  final String value;

  /// 単位を決める指標。
  final PeriodTotalMetric metric;

  /// 期間名を上に、数字を中央に置く。
  ///
  /// Example:
  /// ```dart
  /// _PeriodBox(
  ///   label: '本日',
  ///   value: '--',
  ///   metric: PeriodTotalMetric.calories,
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    final labelStyle = context.theme.typography.body.xs.copyWith(
      color: context.theme.colors.mutedForeground,
    );
    return SizedBox(
      height: 148,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: labelStyle),
            Expanded(
              child: Center(
                child: _HeroValue(value: value, metric: metric),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 合計の数字を大きく、単位を小さく示す。
class _HeroValue extends StatelessWidget {
  /// [value] を [metric] の単位とともに中央へ置く。
  ///
  /// Example:
  /// ```dart
  /// _HeroValue(value: '1.3', metric: PeriodTotalMetric.calories);
  /// ```
  const _HeroValue({required this.value, required this.metric});

  /// 合計の表記。履歴が無いときは `--`。
  final String value;

  /// 単位を決める指標。
  final PeriodTotalMetric metric;

  /// 数字を単位より大きくする。
  ///
  /// Example:
  /// ```dart
  /// _HeroValue(value: '--', metric: PeriodTotalMetric.calories);
  /// ```
  @override
  Widget build(BuildContext context) {
    final numberStyle = context.theme.typography.display.md.copyWith(
      fontSize: 32,
      height: 1.1,
      fontWeight: FontWeight.w700,
    );
    final unitStyle = context.theme.typography.body.sm.copyWith(
      color: context.theme.colors.mutedForeground,
    );
    final duration = RegExp(r'^(\d+)h(\d+)m$').firstMatch(value);
    if (duration != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: duration.group(1), style: numberStyle),
              TextSpan(text: 'h', style: unitStyle),
              TextSpan(text: duration.group(2), style: numberStyle),
              TextSpan(text: 'm', style: unitStyle),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    final unit = _unit(metric);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: numberStyle, textAlign: TextAlign.center),
          if (unit != null) Text(unit, style: unitStyle),
        ],
      ),
    );
  }
}
