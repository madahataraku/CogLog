import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';

import '../can_submit_meter_capture.dart';
import '../state/meter_capture_screen_state.dart';

/// 登録可能条件を満たすとき運動履歴を保存し、ホームへ遷移する。
///
/// Example:
/// ```dart
/// OnSaveMeterCaptureDelegate(
///   state: state,
///   saveMeterCaptureUsecase: saveMeterCaptureUsecase,
///   navigation: navigation,
/// ).execute();
/// ```
final class OnSaveMeterCaptureDelegate {
  /// 保存と遷移の依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSaveMeterCaptureDelegate(
  ///   state: state,
  ///   saveMeterCaptureUsecase: saveMeterCaptureUsecase,
  ///   navigation: navigation,
  /// );
  /// ```
  const OnSaveMeterCaptureDelegate({
    required this.state,
    required this.saveMeterCaptureUsecase,
    required this.navigation,
  });

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// メーター記録の保存。
  final SaveMeterCaptureUsecase saveMeterCaptureUsecase;

  /// ホームタブへの遷移。
  final ScreenNavigation navigation;

  /// 条件を満たせば保存し、成功時は [ScreenNavigation.goToHomeTab] する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    SaveMeterCaptureRequest? request;
    await state.updateWithLock((current, emitter) async {
      if (current.saving ||
          current.inputsInvalid ||
          !canSubmitMeterCapture(
            distanceKm: current.distanceKm,
            duration: current.duration,
            averageSpeedKmh: current.averageSpeedKmh,
            caloriesKcal: current.caloriesKcal,
          )) {
        return;
      }
      final photoBytes = current.photoBytes;
      final creationStartedAt = current.creationStartedAt;
      final capturedAt = current.capturedAt;
      final recordedAt = current.recordedAt;
      if (photoBytes == null ||
          creationStartedAt == null ||
          capturedAt == null ||
          recordedAt == null) {
        return;
      }
      request = SaveMeterCaptureRequest(
        creationStartedAt: creationStartedAt,
        capturedAt: capturedAt,
        recordedAt: recordedAt,
        recordedAtManuallySet: current.recordedAtManuallySet,
        distanceKm: current.distanceKm!,
        duration: current.duration!,
        caloriesKcal: current.caloriesKcal!,
        averageSpeedKmh: current.averageSpeedKmh!,
        photoBytes: photoBytes,
      );
      await emitter.emit(current.copyWith(saving: true, saveError: false));
    });
    final pending = request;
    if (pending == null) {
      return;
    }

    try {
      final result = await saveMeterCaptureUsecase.execute(pending);

      switch (result.outcome) {
        case SaveMeterCaptureOutcome.invalidInput:
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(current.copyWith(saving: false));
          });
        case SaveMeterCaptureOutcome.saveFailed:
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(
              current.copyWith(saving: false, saveError: true),
            );
          });
        case SaveMeterCaptureOutcome.success:
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(MeterCaptureScreenState.initial);
          });
          navigation.goToHomeTab();
      }
    } on Object {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(current.copyWith(saving: false, saveError: true));
      });
    }
  }
}
