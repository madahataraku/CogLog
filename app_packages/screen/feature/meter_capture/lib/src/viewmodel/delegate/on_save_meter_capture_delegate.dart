import 'package:state_stream/state_stream.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';

import '../can_submit_meter_capture.dart';
import '../state/meter_capture_screen_state.dart';

/// メーター記録の保存が成功したときの UI 向け結果。
///
/// Example:
/// ```dart
/// const OnSaveMeterCaptureSuccess(goalAutoUpdated: false);
/// ```
final class OnSaveMeterCaptureSuccess {
  /// [goalAutoUpdated] を持つ成功結果を作る。
  ///
  /// Example:
  /// ```dart
  /// const OnSaveMeterCaptureSuccess(goalAutoUpdated: true);
  /// ```
  const OnSaveMeterCaptureSuccess({required this.goalAutoUpdated});

  /// 保存後の目標自動更新が適用されたか。
  final bool goalAutoUpdated;
}

/// 登録可能条件を満たすとき運動履歴を保存し、成功結果を返す。
///
/// 成功時のホーム遷移は呼び出し側が行う。失敗・未実行は null。
///
/// Example:
/// ```dart
/// OnSaveMeterCaptureDelegate(
///   state: state,
///   saveMeterCaptureUsecase: saveMeterCaptureUsecase,
/// ).execute();
/// ```
final class OnSaveMeterCaptureDelegate {
  /// 保存の依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSaveMeterCaptureDelegate(
  ///   state: state,
  ///   saveMeterCaptureUsecase: saveMeterCaptureUsecase,
  /// );
  /// ```
  const OnSaveMeterCaptureDelegate({
    required this.state,
    required this.saveMeterCaptureUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// メーター記録の保存。
  final SaveMeterCaptureUsecase saveMeterCaptureUsecase;

  /// 条件を満たせば保存し、成功時は [OnSaveMeterCaptureSuccess] を返す。
  ///
  /// ホームへの遷移は行わない。トーストのあと呼び出し側が遷移する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<OnSaveMeterCaptureSuccess?> execute() async {
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
      return null;
    }

    try {
      final result = await saveMeterCaptureUsecase.execute(pending);

      switch (result.outcome) {
        case SaveMeterCaptureOutcome.invalidInput:
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(current.copyWith(saving: false));
          });
          return null;
        case SaveMeterCaptureOutcome.saveFailed:
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(
              current.copyWith(saving: false, saveError: true),
            );
          });
          return null;
        case SaveMeterCaptureOutcome.success:
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(MeterCaptureScreenState.initial);
          });
          return OnSaveMeterCaptureSuccess(
            goalAutoUpdated: result.goalAutoUpdated,
          );
      }
    } on Object {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(current.copyWith(saving: false, saveError: true));
      });
      return null;
    }
  }
}
