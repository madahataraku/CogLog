import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../state/meter_capture_screen_state.dart';
import '../state/meter_capture_step.dart';
import 'on_evaluate_model_download_guidance_delegate.dart';

/// 写真バイトを読み取り、2 ステップ目へ進める。
///
/// Example:
/// ```dart
/// OnReadMeterDelegate(
///   state: state,
///   readMeterPanelUsecase: readMeterPanelUsecase,
///   evaluateOnDeviceLlmGuidanceUsecase: evaluate,
///   guidanceSession: session,
/// ).execute(photoBytes: Uint8List(0));
/// ```
final class OnReadMeterDelegate {
  /// [state]・読み取り・誘導判定を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnReadMeterDelegate(
  ///   state: state,
  ///   readMeterPanelUsecase: readMeterPanelUsecase,
  ///   evaluateOnDeviceLlmGuidanceUsecase: evaluate,
  ///   guidanceSession: session,
  /// );
  /// ```
  const OnReadMeterDelegate({
    required this.state,
    required this.readMeterPanelUsecase,
    required this.evaluateOnDeviceLlmGuidanceUsecase,
    required this.guidanceSession,
  });

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// パネル読み取り。
  final ReadMeterPanelUsecase readMeterPanelUsecase;

  /// モデル未ダウンロード誘導の要否。
  final EvaluateOnDeviceLlmGuidanceUsecase evaluateOnDeviceLlmGuidanceUsecase;

  /// プロセス内の誘導再表示抑制。
  final OnDeviceLlmGuidanceSession guidanceSession;

  /// [photoBytes] を読み、結果を State に載せて edit へ移る。
  ///
  /// 読み取り完了と同一 emit で成功／注意／手打ちの三段を確定する。
  /// 誘導判定は並行して進めるが、メッセージフラグは触らない。
  /// 例外時も空に近い値で 2 ステップ目へ進む。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(photoBytes: Uint8List(0));
  /// ```
  Future<void> execute({
    required Uint8List photoBytes,
    int? expectedGeneration,
  }) async {
    final generation =
        expectedGeneration ?? state.state.cameraSessionGeneration;
    await state.updateWithLock((current, emitter) async {
      if (current.cameraSessionGeneration != generation) {
        return;
      }
      await emitter.emit(
        current.copyWith(
          reading: true,
          saveError: false,
          showReadSuccessMessage: false,
          showReadCautionMessage: false,
          showHandEntryGuidance: false,
        ),
      );
    });

    final guidanceFuture = OnEvaluateModelDownloadGuidanceDelegate(
      state: state,
      evaluateOnDeviceLlmGuidanceUsecase: evaluateOnDeviceLlmGuidanceUsecase,
      guidanceSession: guidanceSession,
    ).execute();

    ReadMeterPanelResult result;
    try {
      result = await readMeterPanelUsecase.execute(
        ReadMeterPanelRequest(photoBytes: photoBytes),
      );
    } on Object {
      result = const ReadMeterPanelResult(
        values: MeterReadingValues(),
        averageSpeedFromPanel: false,
      );
    }

    final values = result.values;
    final kind = classifyMeterReadingMessages(values);
    final resolved = resolveInitialAverageSpeed(merged: values);
    await state.updateWithLock((current, emitter) async {
      if (current.cameraSessionGeneration != generation) {
        return;
      }
      await emitter.emit(
        current.copyWith(
          step: MeterCaptureStep.edit,
          reading: false,
          distanceKm: values.distanceKm,
          clearDistanceKm: values.distanceKm == null,
          duration: values.duration,
          clearDuration: values.duration == null,
          caloriesKcal: values.caloriesKcal,
          clearCaloriesKcal: values.caloriesKcal == null,
          averageSpeedKmh: resolved.speed,
          clearAverageSpeedKmh: resolved.speed == null,
          averageSpeedFromPanel: false,
          averageSpeedUserEdited: false,
          showReadSuccessMessage: kind == MeterReadingMessageKind.complete,
          showReadCautionMessage:
              kind == MeterReadingMessageKind.complete ||
              kind == MeterReadingMessageKind.incomplete,
          showHandEntryGuidance: kind != MeterReadingMessageKind.complete,
          saveError: false,
        ),
      );
    });

    await guidanceFuture;
  }
}
