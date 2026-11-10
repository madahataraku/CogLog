import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

import '../state/meter_capture_screen_state.dart';
import '../state/meter_capture_step.dart';

/// 写真バイトを読み取り、2 ステップ目へ進める。
///
/// Example:
/// ```dart
/// OnReadMeterDelegate(
///   state: state,
///   readMeterPanelUsecase: readMeterPanelUsecase,
/// ).execute(photoBytes: Uint8List(0));
/// ```
final class OnReadMeterDelegate {
  /// [state] と [readMeterPanelUsecase] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnReadMeterDelegate(
  ///   state: state,
  ///   readMeterPanelUsecase: readMeterPanelUsecase,
  /// );
  /// ```
  const OnReadMeterDelegate({
    required this.state,
    required this.readMeterPanelUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// パネル読み取り。
  final ReadMeterPanelUsecase readMeterPanelUsecase;

  /// [photoBytes] を読み、結果を State に載せて edit へ移る。
  ///
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
      await emitter.emit(current.copyWith(reading: true, saveError: false));
    });

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
          averageSpeedKmh: values.averageSpeedKmh,
          clearAverageSpeedKmh: values.averageSpeedKmh == null,
          averageSpeedFromPanel: result.averageSpeedFromPanel,
          averageSpeedUserEdited: false,
          saveError: false,
        ),
      );
    });
  }
}
