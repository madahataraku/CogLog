import 'dart:async';
import 'dart:io';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:foundation_datetime/foundation_datetime.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:view_confirm_dialog/view_confirm_dialog.dart';

import '../strings.dart';
import '../viewmodel/exercise_history_edit_screen_view_model.dart';
import 'exercise_history_edit_screen_providers.dart';

/// 編集フィールド・写真再取得・保存・破棄確認。
///
/// Example:
/// ```dart
/// const ExerciseHistoryEditScreenBody();
/// ```
@internal
class ExerciseHistoryEditScreenBody extends HookConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryEditScreenBody();
  /// ```
  const ExerciseHistoryEditScreenBody({super.key});

  /// Entity を描画し、操作を ViewModel へ渡す。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryEditScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(ExerciseHistoryEditScreenProviders.entity);
    final state = ref.watch(ExerciseHistoryEditScreenProviders.state);
    final viewModel = ref.watch(ExerciseHistoryEditScreenViewModel.provider);

    final distanceController = useTextEditingController();
    final hoursController = useTextEditingController();
    final minutesController = useTextEditingController();
    final secondsController = useTextEditingController();
    final caloriesController = useTextEditingController();
    final languageCode = Localizations.localeOf(context).languageCode;
    final recordedAt = entity.recordedAt;
    final recordedAtLabel = recordedAt == null
        ? ''
        : formatFullLocalDateTime(recordedAt, languageCode: languageCode);

    useEffect(() {
      // 初期読込・写真再読取完了時だけ欄を置換する。別フィールド入力で不正文字列を消さない。
      distanceController.text = entity.distanceText;
      hoursController.text = entity.hoursText;
      minutesController.text = entity.minutesText;
      secondsController.text = entity.secondsText;
      caloriesController.text = entity.caloriesText;
      return null;
    }, [state.fieldsSyncGeneration]);

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
      await viewModel.onRecordedAtChanged(
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

    Future<void> handleBack() async {
      if (entity.busy) {
        return;
      }
      if (entity.isDirty) {
        final ok = await showConfirmDialog(
          context,
          title: strings.screen_feature_exercise_history_edit_discard_title,
          body: strings.screen_feature_exercise_history_edit_discard_body,
          confirmLabel: strings.screen_feature_exercise_history_edit_discard_ok,
          cancelLabel:
              strings.screen_feature_exercise_history_edit_discard_cancel,
        );
        if (!ok) {
          return;
        }
      }
      viewModel.onDiscard();
    }

    final maxPhotoHeight = MediaQuery.sizeOf(context).height * 0.3;

    return PopScope(
      canPop: !entity.isDirty && !entity.busy,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await handleBack();
      },
      child: FScaffold(
        header: FHeader.nested(
          title: Text(strings.screen_feature_exercise_history_edit_title),
          prefixes: [
            FHeaderAction.back(
              onPress: entity.busy
                  ? null
                  : () {
                      unawaited(handleBack());
                    },
            ),
          ],
        ),
        child: entity.showLoading
            ? const Center(child: FCircularProgress())
            : entity.showMissing
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Text(
                      strings.screen_feature_exercise_history_edit_missing,
                      textAlign: TextAlign.center,
                    ),
                    FButton(
                      onPress: viewModel.onDiscard,
                      child: Text(
                        strings.screen_feature_exercise_history_edit_back,
                      ),
                    ),
                  ],
                ),
              )
            : entity.showLoadError
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    FAlert(
                      variant: .destructive,
                      title: Text(entity.loadErrorText ?? ''),
                    ),
                    if (entity.canRetry)
                      FButton(
                        onPress: () => viewModel.onInitialize(id: state.id),
                        child: Text(
                          strings.screen_feature_exercise_history_edit_retry,
                        ),
                      ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    if (entity.showPhotoBytes)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxPhotoHeight),
                        child: Image.memory(
                          state.photoBytes!,
                          fit: BoxFit.contain,
                        ),
                      )
                    else if (entity.showPhotoPath)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxPhotoHeight),
                        child: Image.file(
                          File(entity.photoPath!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Text(
                            strings
                                .screen_feature_exercise_history_edit_photo_error,
                          ),
                        ),
                      )
                    else if (entity.showPhotoError)
                      Text(
                        strings
                            .screen_feature_exercise_history_edit_photo_error,
                      ),
                    if (state.reading) ...[
                      const Center(child: FCircularProgress()),
                      Text(
                        strings.screen_feature_exercise_history_edit_reading,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (entity.showHandEntryGuidance)
                      Text(
                        strings
                            .screen_feature_exercise_history_edit_hand_entry_guidance,
                        textAlign: TextAlign.center,
                      ),
                    if (entity.permissionDeniedText != null) ...[
                      Text(
                        entity.permissionDeniedText!,
                        style: context.theme.typography.body.sm.copyWith(
                          color: context.theme.colors.destructive,
                        ),
                      ),
                      if (entity.showOpenSettings)
                        FButton(
                          onPress: viewModel.onOpenAppSettings,
                          child: Text(
                            strings
                                .screen_feature_exercise_history_edit_open_settings,
                          ),
                        ),
                    ],
                    FTextField(
                      control: .managed(
                        controller: distanceController,
                        onChange: (_) => viewModel.onDistanceChanged(
                          distanceController.text,
                        ),
                      ),
                      label: Text(
                        strings.screen_feature_exercise_history_edit_distance,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      enabled: !entity.busy,
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
                              strings
                                  .screen_feature_exercise_history_edit_duration_hours,
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !entity.busy,
                          ),
                        ),
                        Expanded(
                          child: FTextField(
                            control: .managed(
                              controller: minutesController,
                              onChange: (_) => syncDuration(),
                            ),
                            label: Text(
                              strings
                                  .screen_feature_exercise_history_edit_duration_minutes,
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !entity.busy,
                          ),
                        ),
                        Expanded(
                          child: FTextField(
                            control: .managed(
                              controller: secondsController,
                              onChange: (_) => syncDuration(),
                            ),
                            label: Text(
                              strings
                                  .screen_feature_exercise_history_edit_duration_seconds,
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !entity.busy,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 4,
                      children: [
                        Text(
                          strings
                              .screen_feature_exercise_history_edit_average_speed,
                          style: context.theme.typography.body.sm.copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                        ),
                        Text(
                          entity.averageSpeedText,
                          style: context.theme.typography.body.md,
                        ),
                      ],
                    ),
                    FTextField(
                      control: .managed(
                        controller: caloriesController,
                        onChange: (_) => viewModel.onCaloriesChanged(
                          caloriesController.text,
                        ),
                      ),
                      label: Text(
                        strings.screen_feature_exercise_history_edit_calories,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      enabled: !entity.busy,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [
                        Text(
                          strings
                              .screen_feature_exercise_history_edit_recorded_at,
                        ),
                        TextButton(
                          onPressed: entity.busy ? null : pickExercisedAt,
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            recordedAtLabel,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    if (entity.saveErrorText != null)
                      Text(
                        entity.saveErrorText!,
                        style: context.theme.typography.body.sm.copyWith(
                          color: context.theme.colors.destructive,
                        ),
                      ),
                    FButton(
                      onPress: entity.busy ? null : viewModel.onRetakePhoto,
                      child: Text(
                        strings.screen_feature_exercise_history_edit_retake,
                      ),
                    ),
                    FButton(
                      onPress: entity.busy
                          ? null
                          : viewModel.onPickLibraryPhoto,
                      child: Text(
                        strings
                            .screen_feature_exercise_history_edit_pick_library,
                      ),
                    ),
                    FButton(
                      onPress: !entity.canSave ? null : viewModel.onSave,
                      child: Text(
                        strings.screen_feature_exercise_history_edit_save,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
