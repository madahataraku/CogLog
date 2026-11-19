import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:view_meter_reading_progress/view_meter_reading_progress.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

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

  /// タブ選択とライフサイクルに合わせてカメラを開始／停止し、誘導・読み取りモーダルを出す。
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
    final selected = (ShellTabIndexScope.maybeOf(context) ?? -1) == 1;
    final lifecycle = useAppLifecycleState();

    // 離脱は selected 変化時のみ。世代更新を依存に含めると離脱が再帰する。
    useEffect(() {
      if (!selected) {
        unawaited(viewModel.onLeaveMeterTab());
      }
      return null;
    }, [viewModel, selected]);

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

    useEffect(() {
      if (!entity.pendingModelDownloadGuidance || reading) {
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
    }, [entity.pendingModelDownloadGuidance, reading, viewModel]);

    return const MeterCaptureScreenBody();
  }
}
