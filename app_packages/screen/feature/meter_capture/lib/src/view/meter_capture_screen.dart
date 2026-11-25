import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_coach_mark/view_coach_mark.dart';
import 'package:view_meter_reading_progress/view_meter_reading_progress.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../strings.dart';
import '../viewmodel/meter_capture_screen_view_model.dart';
import '../viewmodel/state/meter_capture_step.dart';
import 'meter_capture_screen_body.dart';
import 'meter_capture_screen_providers.dart';

/// メーターパネル写真から運動履歴を作成する画面。
///
/// Example:
/// ```dart
/// const MeterCaptureScreen();
/// ```
class MeterCaptureScreen extends HookConsumerWidget {
  /// メーター記録画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreen();
  /// ```
  const MeterCaptureScreen({super.key});

  /// タブ選択とライフサイクルに合わせてカメラを開始／停止し、誘導・読み取り・文脈を出す。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(MeterCaptureScreenViewModel.provider);
    final entity = ref.watch(MeterCaptureScreenProviders.entity);
    final step = ref.watch(
      MeterCaptureScreenProviders.state.select((state) => state.step),
    );
    final reading = ref.watch(
      MeterCaptureScreenProviders.state.select((state) => state.reading),
    );
    final cameraSessionGeneration = ref.watch(
      MeterCaptureScreenProviders.state.select(
        (state) => state.cameraSessionGeneration,
      ),
    );
    final tutorialSession = ref.watch(tutorialRuntimeSessionProvider);
    final selected = (ShellTabIndexScope.maybeOf(context) ?? -1) == 1;
    final lifecycle = useAppLifecycleState();
    final foreground =
        lifecycle == null || lifecycle == AppLifecycleState.resumed;

    // 離脱は selected 変化時のみ。世代更新を依存に含めると離脱が再帰する。
    useEffect(() {
      if (!selected) {
        unawaited(viewModel.onLeaveMeterTab());
        CoachMarkLauncher.dismissActive();
        final kind = tutorialSession.activeKind;
        if (kind == TutorialKind.camera || kind == TutorialKind.meterEdit) {
          tutorialSession.clearActive();
        }
      }
      return null;
    }, [viewModel, selected, tutorialSession]);

    useEffect(() {
      if (!selected) {
        return null;
      }
      final paused =
          lifecycle != null && lifecycle != AppLifecycleState.resumed;
      if (paused) {
        unawaited(viewModel.onAppPaused());
        return null;
      }
      if (step == MeterCaptureStep.photo) {
        // 読み取り中止で step が photo のまま世代だけ進む場合も再開する。
        unawaited(viewModel.onEnterCamera());
      } else {
        unawaited(viewModel.onAppPaused());
      }
      return null;
    }, [viewModel, selected, lifecycle, step, cameraSessionGeneration]);

    useEffect(() {
      if (!reading) {
        return null;
      }
      // 読み取り中はコーチマークを隠し、提示済みにしない。
      CoachMarkLauncher.dismissActive();
      unawaited(viewModel.onSuppressTutorialForReading());
      final dismiss = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) {
          return;
        }
        await MeterReadingProgressLauncher.show(
          context,
          onCancel: viewModel.onCancelReading,
          untilDismiss: dismiss.future,
        );
      });
      return () {
        if (!dismiss.isCompleted) {
          dismiss.complete();
        }
      };
    }, [reading, viewModel]);

    // 段階5: 撮影タブ・前面・非読み取りで初回文脈。
    useEffect(() {
      if (!selected || !foreground || reading) {
        return null;
      }
      if (step != MeterCaptureStep.photo) {
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        unawaited(viewModel.onEvaluateTutorialCamera());
      });
      return null;
    }, [viewModel, selected, lifecycle, step, reading]);

    // 段階6: 結果編集の初回表示。
    useEffect(() {
      if (!selected || !foreground || reading) {
        return null;
      }
      if (step != MeterCaptureStep.edit) {
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        unawaited(viewModel.onEvaluateTutorialMeterEdit());
      });
      return null;
    }, [viewModel, selected, lifecycle, step, reading]);

    useEffect(() {
      if (!entity.pendingTutorialCamera || reading) {
        return null;
      }
      if (!selected || !foreground) {
        return null;
      }
      unawaited(viewModel.onAcknowledgeTutorialCamera());
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) {
          return;
        }
        final reason = await CoachMarkLauncher.show(
          context,
          step: CoachMarkStep(
            targetId: CoachMarkTargetId.meterCameraArea,
            title: strings.screen_feature_meter_capture_tutorial_camera_title,
            body: strings.screen_feature_meter_capture_tutorial_camera_body,
            primaryLabel: strings.view_coach_mark_close,
          ),
        );
        if (!context.mounted) {
          return;
        }
        // forced（読み取り優先）では提示済みにしない。
        if (reason == CoachMarkDismissReason.forced) {
          return;
        }
        await viewModel.onDismissTutorialCamera();
      });
      return null;
    }, [entity.pendingTutorialCamera, reading, viewModel, selected, lifecycle]);

    useEffect(
      () {
        if (!entity.pendingTutorialMeterEdit || reading) {
          return null;
        }
        if (!selected || !foreground) {
          return null;
        }
        unawaited(viewModel.onAcknowledgeTutorialMeterEdit());
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) {
            return;
          }
          final reason = await CoachMarkLauncher.show(
            context,
            step: CoachMarkStep(
              targetId: CoachMarkTargetId.meterEditFields,
              title: strings
                  .screen_feature_meter_capture_tutorial_meter_edit_title,
              body:
                  strings.screen_feature_meter_capture_tutorial_meter_edit_body,
              primaryLabel: strings.view_coach_mark_close,
            ),
          );
          if (!context.mounted) {
            return;
          }
          if (reason == CoachMarkDismissReason.forced) {
            return;
          }
          await viewModel.onDismissTutorialMeterEdit();
        });
        return null;
      },
      [
        entity.pendingTutorialMeterEdit,
        reading,
        viewModel,
        selected,
        lifecycle,
      ],
    );

    useEffect(
      () {
        if (!entity.pendingModelDownloadGuidance || reading) {
          return null;
        }
        // チュートリアル表示中はモデル誘導を出さない（提示済みにもしない）。
        if (tutorialSession.isShowing ||
            entity.pendingTutorialCamera ||
            entity.pendingTutorialMeterEdit) {
          return null;
        }
        // 予約時点で同期的に提示済みにし、再入とのレースを防ぐ。
        unawaited(viewModel.onAcknowledgeModelDownloadGuidance());
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) {
            return;
          }
          await ModelDownloadGuidanceLauncher.show(
            context,
            onPrepare: viewModel.onPrepareModelDownloadGuidance,
          );
        });
        return null;
      },
      [
        entity.pendingModelDownloadGuidance,
        entity.pendingTutorialCamera,
        entity.pendingTutorialMeterEdit,
        tutorialSession.isShowing,
        reading,
        viewModel,
      ],
    );

    return const MeterCaptureScreenBody();
  }
}
