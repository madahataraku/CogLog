import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:foundation_datetime/foundation_datetime.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:screen_feature_achievement/screen_feature_achievement.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

import '../strings.dart';
import '../viewmodel/can_submit_meter_capture.dart';
import '../viewmodel/entity/meter_capture_screen_entity.dart';
import '../viewmodel/meter_capture_screen_view_model.dart';
import '../viewmodel/state/meter_capture_screen_state.dart';

/// 計測値の確認・修整と登録。
///
/// Example:
/// ```dart
/// MeterCaptureStep2View(
///   state: MeterCaptureScreenState.initial,
///   entity: const MeterCaptureScreenEntity(
///     distanceText: '',
///     hoursText: '',
///     minutesText: '',
///     secondsText: '',
///     averageSpeedText: '',
///     caloriesText: '',
///     recordedAt: null,
///     pendingModelDownloadGuidance: false,
///     pendingTutorialCamera: false,
///     pendingTutorialMeterEdit: false,
///     showReadSuccessMessage: false,
///     showReadCautionMessage: false,
///     showHandEntryGuidance: false,
///   ),
/// );
/// ```
@internal
class MeterCaptureStep2View extends HookConsumerWidget {
  /// [state] と [entity] を受け取り、操作は ViewModel へ渡す。
  ///
  /// Example:
  /// ```dart
  /// MeterCaptureStep2View(
  ///   state: MeterCaptureScreenState.initial,
  ///   entity: const MeterCaptureScreenEntity(
  ///     distanceText: '',
  ///     hoursText: '',
  ///     minutesText: '',
  ///     secondsText: '',
  ///     averageSpeedText: '',
  ///     caloriesText: '',
  ///     recordedAt: null,
  ///     pendingModelDownloadGuidance: false,
  ///     pendingTutorialCamera: false,
  ///     pendingTutorialMeterEdit: false,
  ///     showReadSuccessMessage: false,
  ///     showReadCautionMessage: false,
  ///     showHandEntryGuidance: false,
  ///   ),
  /// );
  /// ```
  const MeterCaptureStep2View({
    required this.state,
    required this.entity,
    super.key,
  });

  /// 2 ステップ目の作業中状態。
  final MeterCaptureScreenState state;

  /// 入力欄へ流し込む表示文字列。
  final MeterCaptureScreenEntity entity;

  /// 写真プレビューと入力・登録を描画する。
  ///
  /// Example:
  /// ```dart
  /// MeterCaptureStep2View(
  ///   state: MeterCaptureScreenState.initial,
  ///   entity: const MeterCaptureScreenEntity(
  ///     distanceText: '',
  ///     hoursText: '',
  ///     minutesText: '',
  ///     secondsText: '',
  ///     averageSpeedText: '',
  ///     caloriesText: '',
  ///     recordedAt: null,
  ///     pendingModelDownloadGuidance: false,
  ///     pendingTutorialCamera: false,
  ///     pendingTutorialMeterEdit: false,
  ///     showReadSuccessMessage: false,
  ///     showReadCautionMessage: false,
  ///     showHandEntryGuidance: false,
  ///   ),
  /// );
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(MeterCaptureScreenViewModel.provider);
    final distanceController = useTextEditingController();
    final hoursController = useTextEditingController();
    final minutesController = useTextEditingController();
    final secondsController = useTextEditingController();
    final averageSpeedController = useTextEditingController();
    final caloriesController = useTextEditingController();
    final busy = state.reading || state.saving;
    final canSubmit =
        canSubmitMeterCapture(
          distanceKm: state.distanceKm,
          duration: state.duration,
          averageSpeedKmh: state.averageSpeedKmh,
          caloriesKcal: state.caloriesKcal,
        ) &&
        !state.inputsInvalid;
    final languageCode = Localizations.localeOf(context).languageCode;
    final recordedAt = entity.recordedAt;
    final recordedAtLabel = recordedAt == null
        ? ''
        : formatFullLocalDateTime(recordedAt, languageCode: languageCode);

    useEffect(
      () {
        void sync(
          TextEditingController controller,
          String text,
          Object? Function(String) parse,
        ) {
          if (parse(controller.text.trim()) != parse(text)) {
            controller.text = text;
          }
        }

        Object? parseNum(String s) => num.tryParse(s);
        sync(distanceController, entity.distanceText, parseNum);
        sync(hoursController, entity.hoursText, parseNum);
        sync(minutesController, entity.minutesText, parseNum);
        sync(secondsController, entity.secondsText, parseNum);
        sync(averageSpeedController, entity.averageSpeedText, parseNum);
        sync(caloriesController, entity.caloriesText, parseNum);
        return null;
      },
      [
        entity.distanceText,
        entity.hoursText,
        entity.minutesText,
        entity.secondsText,
        entity.averageSpeedText,
        entity.caloriesText,
      ],
    );

    Future<void> syncDuration() => viewModel.onDurationChanged(
      hours: hoursController.text,
      minutes: minutesController.text,
      seconds: secondsController.text,
    );

    Future<void> pickExercisedAt() async {
      final initial = (entity.recordedAt ?? DateTime.now()).toLocal();
      final date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date == null || !context.mounted) {
        return;
      }
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (time == null || !context.mounted) {
        return;
      }
      final keepSecond =
          time.hour == initial.hour && time.minute == initial.minute;
      await viewModel.onExercisedAtChanged(
        DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
          keepSecond ? initial.second : 0,
        ),
      );
    }

    final photoBytes = state.photoBytes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        if (photoBytes != null)
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.memory(photoBytes, fit: BoxFit.cover),
          ),
        if (entity.showReadCautionMessage)
          FAlert(
            variant: .primary,
            title: Text(
              strings.screen_feature_meter_capture_read_complete_title,
            ),
            subtitle: Text(
              strings.screen_feature_meter_capture_read_complete_subtitle,
            ),
          ),
        if (entity.showHandEntryGuidance)
          FAlert(
            variant: .primary,
            title: Text(
              strings.screen_feature_meter_capture_read_missing_title,
            ),
            subtitle: Text(
              strings.screen_feature_meter_capture_read_missing_subtitle,
            ),
          ),
        CoachMarkTarget(
          id: CoachMarkTargetId.meterEditFields,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              FTextField(
                control: .managed(
                  controller: distanceController,
                  onChange: (_) =>
                      viewModel.onDistanceChanged(distanceController.text),
                ),
                label: Text(strings.screen_feature_meter_capture_distance),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: !busy,
              ),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: FTextField(
                      control: .managed(
                        controller: hoursController,
                        onChange: (_) => syncDuration(),
                      ),
                      label: Text(
                        strings.screen_feature_meter_capture_duration_hours,
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !busy,
                    ),
                  ),
                  Expanded(
                    child: FTextField(
                      control: .managed(
                        controller: minutesController,
                        onChange: (_) => syncDuration(),
                      ),
                      label: Text(
                        strings.screen_feature_meter_capture_duration_minutes,
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !busy,
                    ),
                  ),
                  Expanded(
                    child: FTextField(
                      control: .managed(
                        controller: secondsController,
                        onChange: (_) => syncDuration(),
                      ),
                      label: Text(
                        strings.screen_feature_meter_capture_duration_seconds,
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !busy,
                    ),
                  ),
                ],
              ),
              FTextField(
                control: .managed(controller: averageSpeedController),
                label: Text(strings.screen_feature_meter_capture_average_speed),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: false,
              ),
              FTextField(
                control: .managed(
                  controller: caloriesController,
                  onChange: (_) =>
                      viewModel.onCaloriesChanged(caloriesController.text),
                ),
                label: Text(strings.screen_feature_meter_capture_calories),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: !busy,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Text(strings.screen_feature_meter_capture_recorded_at),
                  TextButton(
                    onPressed: busy ? null : pickExercisedAt,
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(recordedAtLabel, textAlign: TextAlign.start),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (state.saveError)
          Text(
            strings.screen_feature_meter_capture_save_failed,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.destructive,
            ),
          ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: FButton(
                variant: .secondary,
                onPress: busy ? null : viewModel.onBackToStep1,
                child: Text(strings.screen_feature_meter_capture_retake),
              ),
            ),
            Expanded(
              child: FButton(
                onPress: !canSubmit || busy
                    ? null
                    : () async {
                        if (await viewModel.shouldShowHealthWriteGuidance()) {
                          if (!context.mounted) {
                            return;
                          }
                          final continued =
                              await _showHealthWriteGuidanceDialog(context);
                          if (!continued) {
                            return;
                          }
                          await viewModel.markHealthWriteGuidanceSeen();
                        }
                        final success = await viewModel.onSave();
                        if (success == null) {
                          return;
                        }
                        if (success.goalAutoUpdated && context.mounted) {
                          showFToast(
                            context: context,
                            title: Text(
                              strings
                                  .screen_feature_meter_capture_goal_auto_updated,
                            ),
                          );
                        }
                        final newly = success.newlyUnlockedAchievements;
                        if (newly.isNotEmpty && context.mounted) {
                          if (newly.length == 1) {
                            final id = newly.first.id;
                            showFToast(
                              context: context,
                              title: Text(
                                strings
                                    .screen_feature_meter_capture_achievement_unlocked_title(
                                      name: resolveAchievementName(id),
                                    ),
                              ),
                              description: Text(
                                strings
                                    .screen_feature_meter_capture_achievement_unlocked_body(
                                      condition: resolveAchievementCondition(
                                        id,
                                      ),
                                    ),
                              ),
                            );
                          } else {
                            final ordered = sortAchievementsByCatalogOrder(
                              newly,
                            );
                            showFToast(
                              context: context,
                              title: Text(
                                strings
                                    .screen_feature_meter_capture_achievement_unlocked_summary_title(
                                      count: '${ordered.length}',
                                      firstName: resolveAchievementName(
                                        ordered.first.id,
                                      ),
                                    ),
                              ),
                            );
                          }
                        }
                        viewModel.goToHomeTab();
                      },
                child: Text(strings.screen_feature_meter_capture_save),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ヘルス書き込み案内を出し、続行なら true。
Future<bool> _showHealthWriteGuidanceDialog(BuildContext context) async {
  final result = await showFDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context, style, animation) {
      return FDialog(
        style: style,
        animation: animation,
        builder: (context, style) {
          const contentPadding = 16.0;
          return Padding(
            padding: const EdgeInsets.all(contentPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: contentPadding,
              children: [
                Text(
                  strings
                      .screen_feature_meter_capture_health_write_guidance_title,
                ),
                Text(
                  strings
                      .screen_feature_meter_capture_health_write_guidance_body,
                ),
                FButton(
                  onPress: () => Navigator.of(context).pop(true),
                  child: Text(
                    strings
                        .screen_feature_meter_capture_health_write_guidance_continue,
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  return result ?? false;
}
