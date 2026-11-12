import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:screen_feature_achievement/screen_feature_achievement.dart';

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
///     recordedAtText: '',
///     pendingModelDownloadGuidance: false,
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
  ///     recordedAtText: '',
  ///     pendingModelDownloadGuidance: false,
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
  ///     recordedAtText: '',
  ///     pendingModelDownloadGuidance: false,
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
    final recordedAtController = useTextEditingController();
    final busy = state.reading || state.saving;
    final canSubmit =
        canSubmitMeterCapture(
          distanceKm: state.distanceKm,
          duration: state.duration,
          averageSpeedKmh: state.averageSpeedKmh,
          caloriesKcal: state.caloriesKcal,
        ) &&
        !state.inputsInvalid;

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
        Object? parseTime(String s) => DateTime.tryParse(s)?.toUtc();
        sync(distanceController, entity.distanceText, parseNum);
        sync(hoursController, entity.hoursText, parseNum);
        sync(minutesController, entity.minutesText, parseNum);
        sync(secondsController, entity.secondsText, parseNum);
        sync(averageSpeedController, entity.averageSpeedText, parseNum);
        sync(caloriesController, entity.caloriesText, parseNum);
        sync(recordedAtController, entity.recordedAtText, parseTime);
        return null;
      },
      [
        entity.distanceText,
        entity.hoursText,
        entity.minutesText,
        entity.secondsText,
        entity.averageSpeedText,
        entity.caloriesText,
        entity.recordedAtText,
      ],
    );

    Future<void> syncDuration() => viewModel.onDurationChanged(
      hours: hoursController.text,
      minutes: minutesController.text,
      seconds: secondsController.text,
    );

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
        if (state.reading) ...[
          const Center(child: FCircularProgress()),
          Text(
            strings.screen_feature_meter_capture_reading,
            textAlign: TextAlign.center,
          ),
        ],
        if (entity.showHandEntryGuidance)
          Text(
            strings.screen_feature_meter_capture_hand_entry_guidance,
            textAlign: TextAlign.center,
          ),
        FTextField(
          control: .managed(
            controller: distanceController,
            onChange: (_) =>
                viewModel.onDistanceChanged(distanceController.text),
          ),
          label: Text(strings.screen_feature_meter_capture_distance),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          control: .managed(
            controller: averageSpeedController,
            onChange: (_) =>
                viewModel.onAverageSpeedChanged(averageSpeedController.text),
          ),
          label: Text(strings.screen_feature_meter_capture_average_speed),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: !busy,
        ),
        FTextField(
          control: .managed(
            controller: caloriesController,
            onChange: (_) =>
                viewModel.onCaloriesChanged(caloriesController.text),
          ),
          label: Text(strings.screen_feature_meter_capture_calories),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: !busy,
        ),
        FTextField(
          control: .managed(
            controller: recordedAtController,
            onChange: (_) =>
                viewModel.onRecordedAtChanged(recordedAtController.text),
          ),
          label: Text(strings.screen_feature_meter_capture_recorded_at),
          enabled: !busy,
        ),
        if (state.saveError)
          Text(
            strings.screen_feature_meter_capture_save_failed,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.destructive,
            ),
          ),
        FButton(
          onPress: busy ? null : viewModel.onBackToStep1,
          child: Text(strings.screen_feature_meter_capture_retake),
        ),
        FButton(
          onPress: !canSubmit || busy
              ? null
              : () async {
                  final success = await viewModel.onSave();
                  if (success == null) {
                    return;
                  }
                  if (success.goalAutoUpdated && context.mounted) {
                    showFToast(
                      context: context,
                      title: Text(
                        strings.screen_feature_meter_capture_goal_auto_updated,
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
                                condition: resolveAchievementCondition(id),
                              ),
                        ),
                      );
                    } else {
                      final ordered = sortAchievementsByCatalogOrder(newly);
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
      ],
    );
  }
}
