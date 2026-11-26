import 'dart:async';

import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/entity/exercise_history_edit_screen_entity.dart';
import 'exercise_history_edit_camera_preview.dart';
import 'exercise_history_edit_camera_shutter_button.dart';

/// 編集画面のアプリ内カメラ phase。ライブラリ操作は出さない。
///
/// Example:
/// ```dart
/// ExerciseHistoryEditCameraPhaseView(
///   entity: entity,
///   preview: const SizedBox.shrink(),
///   onOpenSettings: () async {},
///   onCapture: () async {},
/// );
/// ```
@internal
class ExerciseHistoryEditCameraPhaseView extends StatelessWidget {
  /// [entity] とプレビュー、操作コールバックを受け取る。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryEditCameraPhaseView(
  ///   entity: entity,
  ///   preview: const SizedBox.shrink(),
  ///   onOpenSettings: () async {},
  ///   onCapture: () async {},
  ///   debugPlaceholder: true,
  /// );
  /// ```
  const ExerciseHistoryEditCameraPhaseView({
    required this.entity,
    required this.preview,
    required this.onOpenSettings,
    required this.onCapture,
    this.debugPlaceholder = false,
    super.key,
  });

  /// カメラ phase の表示フラグ。
  final ExerciseHistoryEditScreenEntity entity;

  /// ViewModel 経由のライブプレビュー。
  final Widget preview;

  /// OS のアプリ設定を開く。
  final Future<void> Function() onOpenSettings;

  /// シャッター。
  final Future<void> Function() onCapture;

  /// Golden 用にプレビューを色枠へ差し替える。
  final bool debugPlaceholder;

  /// プレビュー領域とシャッター列を描画する。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryEditCameraPhaseView(
  ///   entity: entity,
  ///   preview: const SizedBox.shrink(),
  ///   onOpenSettings: () async {},
  ///   onCapture: () async {},
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildPreviewArea(context)),
        if (entity.cameraCaptureFailed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              strings.screen_feature_exercise_history_edit_camera_failed,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.destructive,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Center(
            child: ExerciseHistoryEditCameraShutterButton(
              onPress: entity.shutterEnabled
                  ? () => unawaited(onCapture())
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  /// ready / 初期化中 / 権限拒否 / 失敗ごとのプレビュー領域を作る。
  ///
  /// Example:
  /// ```dart
  /// _buildPreviewArea(context);
  /// ```
  Widget _buildPreviewArea(BuildContext context) {
    if (entity.cameraReady) {
      return ExerciseHistoryEditCameraPreview(
        aspectRatio: entity.cameraPreviewAspectRatio ?? 0.75,
        preview: preview,
        debugPlaceholder: debugPlaceholder,
      );
    }
    if (entity.cameraPermissionDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Text(
                strings.screen_feature_exercise_history_edit_permission_camera,
                textAlign: TextAlign.center,
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.destructive,
                ),
              ),
              FButton(
                onPress: entity.busy ? null : () => unawaited(onOpenSettings()),
                child: Text(
                  strings.screen_feature_exercise_history_edit_open_settings,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (entity.cameraFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            strings.screen_feature_exercise_history_edit_camera_failed,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return const Center(child: FCircularProgress());
  }
}
