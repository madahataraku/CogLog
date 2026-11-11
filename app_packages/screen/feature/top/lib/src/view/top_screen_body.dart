import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/entity/top_goal_ring_entity.dart';
import '../viewmodel/top_screen_view_model.dart';
import 'advice_speech_panel.dart';
import 'goal_achievement_ring.dart';
import 'top_screen_providers.dart';

/// 期間の合計と指標の切り替え、吹き出し付きアドバイス、目標達成率。
@internal
class TopScreenBody extends HookConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const TopScreenBody();
  /// ```
  const TopScreenBody({super.key});

  /// 指標の Select、3 期間、[AdviceSpeechPanel]、達成率リングを縦に並べる。
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
    return FScaffold(
      header: FHeader(
        title: Text(strings.foundation_resources_app_name),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.trophy),
            onPress: viewModel.onOpenAchievements,
            semanticsLabel: strings.screen_feature_top_achievements_semantics,
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
            FSelectMenuTile<PeriodTotalMetric>.fromMap(
              {
                for (final metric in PeriodTotalMetric.values)
                  _metricLabel(metric): metric,
              },
              title: Text(_metricLabel(entity.metric)),
              enabled: !saving.value,
              selectControl: .lifted(
                value: {entity.metric},
                onChange: (values) async {
                  final metric = values.difference({entity.metric}).firstOrNull;
                  if (metric == null ||
                      metric == entity.metric ||
                      saving.value) {
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
            ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: _PeriodBox(
                    label: strings.screen_feature_top_today,
                    value: entity.todayText,
                    metric: entity.metric,
                  ),
                ),
                Expanded(
                  child: _PeriodBox(
                    label: strings.screen_feature_top_this_week,
                    value: entity.weekText,
                    metric: entity.metric,
                  ),
                ),
                Expanded(
                  child: _PeriodBox(
                    label: strings.screen_feature_top_this_month,
                    value: entity.monthText,
                    metric: entity.metric,
                  ),
                ),
              ],
            ),
            if (entity.adviceText.isNotEmpty)
              AdviceSpeechPanel(
                adviceText: entity.adviceText,
                tone: entity.adviceTone,
                semanticsLabel: strings.screen_feature_top_advisor_semantics,
              ),
            Text(
              strings.screen_feature_top_achievement_title,
              style: titleStyle,
            ),
            Row(
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

/// [metric] の表示名。
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
    return FCard(
      child: SizedBox(
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
