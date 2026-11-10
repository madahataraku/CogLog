import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/delegate/on_save_delegate.dart';
import '../viewmodel/goal_settings_screen_view_model.dart';
import 'goal_settings_screen_providers.dart';

/// 運動時間・カロリー・距離・自動更新の入力と保存。
///
/// Example:
/// ```dart
/// const GoalSettingsScreenBody();
/// ```
@internal
class GoalSettingsScreenBody extends HookConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const GoalSettingsScreenBody();
  /// ```
  const GoalSettingsScreenBody({super.key});

  /// 各欄の controller を Entity と同期し、保存ボタンで ViewModel へ渡す。
  ///
  /// Example:
  /// ```dart
  /// const GoalSettingsScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(GoalSettingsScreenProviders.entity);
    final hoursController = useTextEditingController();
    final minutesController = useTextEditingController();
    final secondsController = useTextEditingController();
    final caloriesController = useTextEditingController();
    final distanceController = useTextEditingController();
    final autoUpdateEnabled = useState(entity.autoUpdateEnabled);
    final autoUpdateLevel = useState(entity.autoUpdateLevel);
    final saving = useState(false);

    useEffect(
      () {
        if (!entity.loaded) {
          return null;
        }
        hoursController.text = entity.hours;
        minutesController.text = entity.minutes;
        secondsController.text = entity.seconds;
        caloriesController.text = entity.calories;
        distanceController.text = entity.distance;
        autoUpdateEnabled.value = entity.autoUpdateEnabled;
        autoUpdateLevel.value = entity.autoUpdateLevel;
        return null;
      },
      [
        entity.loaded,
        entity.hours,
        entity.minutes,
        entity.seconds,
        entity.calories,
        entity.distance,
        entity.autoUpdateEnabled,
        entity.autoUpdateLevel,
      ],
    );

    return FScaffold(
      header: FHeader(title: Text(strings.screen_feature_goal_settings_title)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text(strings.screen_feature_goal_settings_duration_label),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: FTextField(
                    control: .managed(controller: hoursController),
                    label: Text(
                      strings.screen_feature_goal_settings_hours_label,
                    ),
                    keyboardType: TextInputType.number,
                    enabled: entity.loaded && !saving.value,
                  ),
                ),
                Expanded(
                  child: FTextField(
                    control: .managed(controller: minutesController),
                    label: Text(
                      strings.screen_feature_goal_settings_minutes_label,
                    ),
                    keyboardType: TextInputType.number,
                    enabled: entity.loaded && !saving.value,
                  ),
                ),
                Expanded(
                  child: FTextField(
                    control: .managed(controller: secondsController),
                    label: Text(
                      strings.screen_feature_goal_settings_seconds_label,
                    ),
                    keyboardType: TextInputType.number,
                    enabled: entity.loaded && !saving.value,
                  ),
                ),
              ],
            ),
            FTextField(
              control: .managed(controller: caloriesController),
              label: Text(strings.screen_feature_goal_settings_calories_label),
              description: Text(
                strings.screen_feature_goal_settings_calories_unit,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              enabled: entity.loaded && !saving.value,
            ),
            FTextField(
              control: .managed(controller: distanceController),
              label: Text(strings.screen_feature_goal_settings_distance_label),
              description: Text(
                strings.screen_feature_goal_settings_distance_unit,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              enabled: entity.loaded && !saving.value,
            ),
            FSwitch(
              label: Text(
                strings.screen_feature_goal_settings_auto_update_enabled,
              ),
              description: Text(
                strings.screen_feature_goal_settings_auto_update_description,
              ),
              value: autoUpdateEnabled.value,
              onChange: entity.loaded && !saving.value
                  ? (value) => autoUpdateEnabled.value = value
                  : null,
              enabled: entity.loaded && !saving.value,
            ),
            FSelect<DailyGoalAutoUpdateLevel>(
              enabled: entity.loaded && !saving.value,
              label: Text(
                strings.screen_feature_goal_settings_auto_update_level,
              ),
              control: .lifted(
                value: autoUpdateLevel.value,
                onChange: (level) {
                  if (level == null ||
                      level == autoUpdateLevel.value ||
                      saving.value) {
                    return;
                  }
                  autoUpdateLevel.value = level;
                },
              ),
              items: {
                for (final level in DailyGoalAutoUpdateLevel.values)
                  _autoUpdateLevelLabel(level): level,
              },
            ),
            Text(
              strings.screen_feature_goal_settings_unset_hint,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            FButton(
              onPress: !entity.loaded || saving.value
                  ? null
                  : () async {
                      saving.value = true;
                      try {
                        final outcome = await ref
                            .read(GoalSettingsScreenViewModel.provider)
                            .onSave(
                              hours: hoursController.text,
                              minutes: minutesController.text,
                              seconds: secondsController.text,
                              calories: caloriesController.text,
                              distance: distanceController.text,
                              autoUpdateEnabled: autoUpdateEnabled.value,
                              autoUpdateLevel: autoUpdateLevel.value,
                            );
                        if (!context.mounted) {
                          return;
                        }
                        final title = switch (outcome) {
                          GoalSettingsSaveOutcome.success =>
                            strings.screen_feature_goal_settings_save_success,
                          GoalSettingsSaveOutcome.invalidInput =>
                            strings
                                .screen_feature_goal_settings_save_invalid_input,
                          GoalSettingsSaveOutcome.saveFailed =>
                            strings.screen_feature_goal_settings_save_failed,
                        };
                        showFToast(
                          context: context,
                          title: Text(title),
                          variant: switch (outcome) {
                            GoalSettingsSaveOutcome.success => .primary,
                            GoalSettingsSaveOutcome.invalidInput ||
                            GoalSettingsSaveOutcome.saveFailed => .destructive,
                          },
                        );
                      } finally {
                        saving.value = false;
                      }
                    },
              child: Text(strings.screen_feature_goal_settings_save),
            ),
          ],
        ),
      ),
    );
  }
}

/// [level] の表示名。
///
/// Example:
/// ```dart
/// _autoUpdateLevelLabel(DailyGoalAutoUpdateLevel.normal);
/// ```
String _autoUpdateLevelLabel(DailyGoalAutoUpdateLevel level) => switch (level) {
  DailyGoalAutoUpdateLevel.slow =>
    strings.screen_feature_goal_settings_auto_update_level_slow,
  DailyGoalAutoUpdateLevel.normal =>
    strings.screen_feature_goal_settings_auto_update_level_normal,
  DailyGoalAutoUpdateLevel.challenging =>
    strings.screen_feature_goal_settings_auto_update_level_challenging,
};
