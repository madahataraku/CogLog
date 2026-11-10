import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';

import '../strings.dart';
import '../viewmodel/meter_capture_screen_view_model.dart';
import '../viewmodel/state/meter_capture_camera_ui.dart';
import '../viewmodel/state/meter_capture_screen_state.dart';
import 'meter_capture_camera_preview.dart';
import 'meter_capture_shutter_button.dart';

/// アプリ内カメラとライブラリ選択。
///
/// Example:
/// ```dart
/// MeterCaptureStep1View(state: MeterCaptureScreenState.initial);
/// ```
@internal
class MeterCaptureStep1View extends ConsumerWidget {
  /// [state] を受け取り、操作は ViewModel へ渡す。
  ///
  /// Example:
  /// ```dart
  /// MeterCaptureStep1View(state: MeterCaptureScreenState.initial);
  /// ```
  const MeterCaptureStep1View({
    required this.state,
    this.debugPlaceholder = false,
    super.key,
  });

  /// 1 ステップ目の表示に使う状態。
  final MeterCaptureScreenState state;

  /// Golden 用にプレビューを色枠へ差し替える。
  final bool debugPlaceholder;

  /// カメラ UI を描画する。
  ///
  /// Example:
  /// ```dart
  /// MeterCaptureStep1View(state: MeterCaptureScreenState.initial);
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(MeterCaptureScreenViewModel.provider);
    final busy = state.reading || state.saving;
    final shutterEnabled =
        !busy && state.cameraUi == MeterCaptureCameraUi.ready;
    final libraryEnabled = !busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildPreviewArea(context, viewModel)),
        if (state.captureError)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              strings.screen_feature_meter_capture_capture_failed,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.destructive,
              ),
            ),
          ),
        if (state.permissionDeniedKind == MeterPhotoPermissionKind.library) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              strings.screen_feature_meter_capture_permission_library,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.destructive,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: FButton(
              onPress: busy ? null : viewModel.onOpenAppSettings,
              child: Text(strings.screen_feature_meter_capture_open_settings),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: FButton(
                        onPress: libraryEnabled
                            ? viewModel.onPickLibraryPhoto
                            : null,
                        child: Text(
                          strings.screen_feature_meter_capture_pick_library,
                        ),
                      ),
                    ),
                  ),
                ),
                MeterCaptureShutterButton(
                  onPress: shutterEnabled ? viewModel.onCapturePhoto : null,
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 読み取り中オーバーレイと [MeterCaptureCameraUi] ごとのプレビュー領域を作る。
  ///
  /// Example:
  /// ```dart
  /// _buildPreviewArea(context, viewModel);
  /// ```
  Widget _buildPreviewArea(
    BuildContext context,
    MeterCaptureScreenViewModel viewModel,
  ) {
    if (state.reading) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (state.cameraUi == MeterCaptureCameraUi.ready)
            MeterCaptureCameraPreview(
              aspectRatio: state.previewAspectRatio,
              preview: viewModel.buildCameraPreview(),
              debugPlaceholder: debugPlaceholder,
            ),
          const ColoredBox(color: Color(0x66000000)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                const FCircularProgress(),
                Text(strings.screen_feature_meter_capture_reading),
              ],
            ),
          ),
        ],
      );
    }

    return switch (state.cameraUi) {
      MeterCaptureCameraUi.ready => MeterCaptureCameraPreview(
        aspectRatio: state.previewAspectRatio,
        preview: viewModel.buildCameraPreview(),
        debugPlaceholder: debugPlaceholder,
      ),
      MeterCaptureCameraUi.starting ||
      MeterCaptureCameraUi.idle => const Center(child: FCircularProgress()),
      MeterCaptureCameraUi.permissionDenied => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text(
                strings.screen_feature_meter_capture_permission_camera,
                textAlign: TextAlign.center,
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.destructive,
                ),
              ),
              FButton(
                onPress: state.saving ? null : viewModel.onOpenAppSettings,
                child: Text(strings.screen_feature_meter_capture_open_settings),
              ),
            ],
          ),
        ),
      ),
      MeterCaptureCameraUi.failed => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            strings.screen_feature_meter_capture_camera_preview_failed,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    };
  }
}
