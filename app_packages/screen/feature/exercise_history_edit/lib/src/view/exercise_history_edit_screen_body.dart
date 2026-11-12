import 'dart:async';
import 'dart:io';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
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
    final recordedAtController = useTextEditingController();

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
        sync(caloriesController, entity.caloriesText, parseNum);
        sync(recordedAtController, entity.recordedAtText, parseTime);
        return null;
      },
      [
        entity.distanceText,
        entity.hoursText,
        entity.minutesText,
        entity.secondsText,
        entity.caloriesText,
        entity.recordedAtText,
      ],
    );

    Future<void> syncDuration() => viewModel.onDurationChanged(
      hours: hoursController.text,
      minutes: minutesController.text,
      seconds: secondsController.text,
    );

    Future<void> handleBack() async {
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
      canPop: !entity.isDirty,
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
                    FTextField(
                      control: .managed(
                        controller: recordedAtController,
                        onChange: (_) => viewModel.onRecordedAtChanged(
                          recordedAtController.text,
                        ),
                      ),
                      label: Text(
                        strings
                            .screen_feature_exercise_history_edit_recorded_at,
                      ),
                      enabled: !entity.busy,
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
