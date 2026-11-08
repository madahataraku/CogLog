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
    final snapshot = state.state;
    if (snapshot.inputsInvalid ||
        !canSubmitMeterCapture(
          distanceKm: snapshot.distanceKm,
          duration: snapshot.duration,
          averageSpeedKmh: snapshot.averageSpeedKmh,
          caloriesKcal: snapshot.caloriesKcal,
        )) {
      return;
    }
    final photoBytes = snapshot.photoBytes;
    final creationStartedAt = snapshot.creationStartedAt;
    final capturedAt = snapshot.capturedAt;
    final recordedAt = snapshot.recordedAt;
    if (photoBytes == null ||
        creationStartedAt == null ||
        capturedAt == null ||
        recordedAt == null) {
      return;
    }

    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(saving: true, saveError: false));
    });

    try {
      final result = await saveMeterCaptureUsecase.execute(
        SaveMeterCaptureRequest(
          creationStartedAt: creationStartedAt,
          capturedAt: capturedAt,
          recordedAt: recordedAt,
          recordedAtManuallySet: snapshot.recordedAtManuallySet,
          distanceKm: snapshot.distanceKm!,
          duration: snapshot.duration!,
          caloriesKcal: snapshot.caloriesKcal!,
          averageSpeedKmh: snapshot.averageSpeedKmh!,
          photoBytes: photoBytes,
        ),
      );

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
