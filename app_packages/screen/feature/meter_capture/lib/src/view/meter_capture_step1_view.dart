import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';

import '../strings.dart';
import '../viewmodel/meter_capture_screen_view_model.dart';
import '../viewmodel/state/meter_capture_screen_state.dart';

/// 撮影・ライブラリ選択と権限案内。
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
  const MeterCaptureStep1View({required this.state, super.key});

  /// 1 ステップ目の表示に使う状態。
  final MeterCaptureScreenState state;

  /// 撮影・ライブラリ・権限案内を描画する。
  ///
  /// Example:
  /// ```dart
  /// MeterCaptureStep1View(state: MeterCaptureScreenState.initial);
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(MeterCaptureScreenViewModel.provider);
    final busy = state.reading || state.saving;
    final permission = state.permissionDeniedKind;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        if (state.reading) ...[
          const Center(child: FCircularProgress()),
          Text(
            strings.screen_feature_meter_capture_reading,
            textAlign: TextAlign.center,
          ),
        ],
        FButton(
          onPress: busy ? null : viewModel.onCapturePhoto,
          child: Text(strings.screen_feature_meter_capture_capture_photo),
        ),
        FButton(
          onPress: busy ? null : viewModel.onPickLibraryPhoto,
          child: Text(strings.screen_feature_meter_capture_pick_library),
        ),
        if (permission != null) ...[
          Text(
            switch (permission) {
              MeterPhotoPermissionKind.camera =>
                strings.screen_feature_meter_capture_permission_camera,
              MeterPhotoPermissionKind.library =>
                strings.screen_feature_meter_capture_permission_library,
            },
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.destructive,
            ),
          ),
          FButton(
            onPress: busy ? null : viewModel.onOpenAppSettings,
            child: Text(strings.screen_feature_meter_capture_open_settings),
          ),
        ],
      ],
    );
  }
}
