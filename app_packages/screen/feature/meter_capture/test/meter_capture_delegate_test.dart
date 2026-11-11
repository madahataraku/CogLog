import 'dart:async';
import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/can_submit_meter_capture.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/meter_capture_state_to_entity_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/on_acknowledge_model_download_guidance_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/on_back_to_step1_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/on_capture_photo_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/on_field_changed_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/on_read_meter_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/on_save_meter_capture_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_camera_ui.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_screen_state.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_step.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

final class _Obtain implements ObtainMeterPhotoUsecase {
  _Obtain(this.result);

  final ObtainMeterPhotoResult result;
  var calls = 0;
  ObtainMeterPhotoSource? lastSource;

  @override
  Future<ObtainMeterPhotoResult> execute(
    ObtainMeterPhotoRequest request,
  ) async {
    calls += 1;
    lastSource = request.source;
    return result;
  }
}

final class _DeferredObtain implements ObtainMeterPhotoUsecase {
  _DeferredObtain(this.pending);

  final Completer<ObtainMeterPhotoResult> pending;
  var calls = 0;

  @override
  Future<ObtainMeterPhotoResult> execute(
    ObtainMeterPhotoRequest request,
  ) async {
    calls += 1;
    return pending.future;
  }
}

final class _Read implements ReadMeterPanelUsecase {
  _Read(this.result, {this.delay = Duration.zero});

  final ReadMeterPanelResult result;
  final Duration delay;
  var calls = 0;

  @override
  Future<ReadMeterPanelResult> execute(ReadMeterPanelRequest request) async {
    calls += 1;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return result;
  }
}

final class _Evaluate implements EvaluateOnDeviceLlmGuidanceUsecase {
  _Evaluate({this.shouldShow = false, this.delay = Duration.zero});

  final bool shouldShow;
  final Duration delay;
  var calls = 0;

  @override
  Future<OnDeviceLlmGuidanceDecision> execute() async {
    calls += 1;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return OnDeviceLlmGuidanceDecision(shouldShow: shouldShow);
  }
}

final class _Save implements SaveMeterCaptureUsecase {
  /// [result] か [pending] のどちらかで応答を決める。
  ///
  /// Example:
  /// ```dart
  /// _Save(result: const SaveMeterCaptureResult(
  ///   outcome: SaveMeterCaptureOutcome.success,
  /// ));
  /// ```
  _Save({this.result, this.pending});

  final SaveMeterCaptureResult? result;

  /// 保存中の競合を再現する未完了 Future。
  final Future<SaveMeterCaptureResult>? pending;

  /// 直近の [execute] に渡された要求。
  SaveMeterCaptureRequest? lastRequest;
  var calls = 0;

  @override
  Future<SaveMeterCaptureResult> execute(
    SaveMeterCaptureRequest request,
  ) async {
    calls += 1;
    lastRequest = request;
    if (pending != null) {
      return pending!;
    }
    return result ??
        const SaveMeterCaptureResult(outcome: SaveMeterCaptureOutcome.success);
  }
}

void main() {
  late MutableStateStream<MeterCaptureScreenState> state;

  setUp(() {
    state = MutableStateStream(MeterCaptureScreenState.initial);
  });

  tearDown(() async {
    await state.close();
  });

  Future<void> readyCamera() async {
    await state.updateWithLock((_, emitter) async {
      await emitter.emit(
        const MeterCaptureScreenState(
          step: MeterCaptureStep.photo,
          cameraUi: MeterCaptureCameraUi.ready,
        ),
      );
    });
  }

  test('D1: 撮影 null は captureError', () async {
    await readyCamera();
    final obtain = _Obtain(const ObtainMeterPhotoCancelled());
    final read = _Read(
      const ReadMeterPanelResult(
        values: MeterReadingValues(),
        averageSpeedFromPanel: false,
      ),
    );

    await OnCapturePhotoDelegate(
      state: state,
      obtainMeterPhotoUsecase: obtain,
      readMeterPanelUsecase: read,
      evaluateOnDeviceLlmGuidanceUsecase: _Evaluate(),
      guidanceSession: OnDeviceLlmGuidanceSession(),
    ).execute();

    expect(obtain.calls, 1);
    expect(obtain.lastSource, ObtainMeterPhotoSource.camera);
    expect(read.calls, 0);
    expect(state.state.step, MeterCaptureStep.photo);
    expect(state.state.photoBytes, isNull);
    expect(state.state.captureError, isTrue);
  });

  test('離脱で世代が進むと撮影成功を捨てる', () async {
    await readyCamera();
    final pending = Completer<ObtainMeterPhotoResult>();
    final obtain = _DeferredObtain(pending);
    final read = _Read(
      const ReadMeterPanelResult(
        values: MeterReadingValues(),
        averageSpeedFromPanel: false,
      ),
    );

    final capture = OnCapturePhotoDelegate(
      state: state,
      obtainMeterPhotoUsecase: obtain,
      readMeterPanelUsecase: read,
      evaluateOnDeviceLlmGuidanceUsecase: _Evaluate(),
      guidanceSession: OnDeviceLlmGuidanceSession(),
    ).execute();

    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          cameraSessionGeneration: current.cameraSessionGeneration + 1,
        ),
      );
    });
    pending.complete(
      ObtainMeterPhotoSuccess(bytes: Uint8List.fromList(const [1, 2, 3])),
    );
    await capture;

    expect(obtain.calls, 1);
    expect(read.calls, 0);
    expect(state.state.step, MeterCaptureStep.photo);
    expect(state.state.photoBytes, isNull);
    expect(state.state.captureError, isFalse);
  });

  test('D2: 権限拒否は permissionDeniedKind=camera', () async {
    await readyCamera();
    final obtain = _Obtain(
      const ObtainMeterPhotoPermissionDenied(MeterPhotoPermissionKind.camera),
    );
    final read = _Read(
      const ReadMeterPanelResult(
        values: MeterReadingValues(),
        averageSpeedFromPanel: false,
      ),
    );

    await OnCapturePhotoDelegate(
      state: state,
      obtainMeterPhotoUsecase: obtain,
      readMeterPanelUsecase: read,
      evaluateOnDeviceLlmGuidanceUsecase: _Evaluate(),
      guidanceSession: OnDeviceLlmGuidanceSession(),
    ).execute();

    expect(read.calls, 0);
    expect(state.state.permissionDeniedKind, MeterPhotoPermissionKind.camera);
    expect(state.state.step, MeterCaptureStep.photo);
  });

  test('D3: back で step2→1 は initial 相当', () async {
    await state.updateWithLock((_, emitter) async {
      await emitter.emit(
        MeterCaptureScreenState(
          step: MeterCaptureStep.edit,
          photoBytes: Uint8List.fromList(const [1, 2, 3]),
          creationStartedAt: DateTime(2026, 11, 8),
          capturedAt: DateTime(2026, 11, 8),
          distanceKm: 1,
          duration: const Duration(minutes: 30),
          caloriesKcal: 100,
          averageSpeedKmh: 2,
          recordedAt: DateTime(2026, 11, 8),
          recordedAtManuallySet: true,
          saveError: true,
        ),
      );
    });

    await OnBackToStep1Delegate(state: state).execute();

    expect(state.state.step, MeterCaptureStep.photo);
    expect(state.state.photoBytes, isNull);
    expect(state.state.distanceKm, isNull);
    expect(state.state.duration, isNull);
    expect(state.state.caloriesKcal, isNull);
    expect(state.state.averageSpeedKmh, isNull);
    expect(state.state.recordedAt, isNull);
    expect(state.state.recordedAtManuallySet, isFalse);
    expect(state.state.saveError, isFalse);
  });

  test('D4: save ok で成功結果を返し遷移は呼び出し側', () async {
    final at = DateTime(2026, 11, 8, 12);
    await state.updateWithLock((_, emitter) async {
      await emitter.emit(
        MeterCaptureScreenState(
          step: MeterCaptureStep.edit,
          photoBytes: Uint8List.fromList(const [1]),
          creationStartedAt: at,
          capturedAt: at,
          distanceKm: 1,
          duration: const Duration(minutes: 30),
          caloriesKcal: 100,
          averageSpeedKmh: 2,
          recordedAt: at,
        ),
      );
    });
    final save = _Save();

    final success = await OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: save,
    ).execute();

    expect(save.calls, 1);
    expect(success, isNotNull);
    expect(success!.goalAutoUpdated, isFalse);
    expect(state.state.saveError, isFalse);
    expect(state.state.saving, isFalse);
    expect(state.state.step, MeterCaptureStep.photo);
    expect(state.state.photoBytes, isNull);
  });

  test('save ok で goalAutoUpdated を成功結果へ写す', () async {
    final at = DateTime(2026, 11, 8, 12);
    await state.updateWithLock((_, emitter) async {
      await emitter.emit(
        MeterCaptureScreenState(
          step: MeterCaptureStep.edit,
          photoBytes: Uint8List.fromList(const [1]),
          creationStartedAt: at,
          capturedAt: at,
          distanceKm: 1,
          duration: const Duration(minutes: 30),
          caloriesKcal: 100,
          averageSpeedKmh: 2,
          recordedAt: at,
        ),
      );
    });
    final save = _Save(
      result: const SaveMeterCaptureResult(
        outcome: SaveMeterCaptureOutcome.success,
        goalAutoUpdated: true,
      ),
    );

    final success = await OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: save,
    ).execute();

    expect(success?.goalAutoUpdated, isTrue);
  });

  test('saveFailed は saveError を立て成功結果を返さない', () async {
    final at = DateTime(2026, 11, 8, 12);
    await state.updateWithLock((_, emitter) async {
      await emitter.emit(
        MeterCaptureScreenState(
          step: MeterCaptureStep.edit,
          photoBytes: Uint8List.fromList(const [1]),
          creationStartedAt: at,
          capturedAt: at,
          distanceKm: 1,
          duration: const Duration(minutes: 30),
          caloriesKcal: 100,
          averageSpeedKmh: 2,
          recordedAt: at,
        ),
      );
    });
    final save = _Save(
      result: const SaveMeterCaptureResult(
        outcome: SaveMeterCaptureOutcome.saveFailed,
      ),
    );

    final success = await OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: save,
    ).execute();

    expect(success, isNull);
    expect(state.state.saveError, isTrue);
    expect(state.state.step, MeterCaptureStep.edit);
  });

  for (final outcome in SaveMeterCaptureOutcome.values) {
    test('日付をまたぐセッションの保存結果 ${outcome.name} を処理する', () async {
      final at = DateTime(2026, 12, 31, 23, 50);
      final photo = Uint8List.fromList([1, 2]);
      await state.updateWithLock((_, emitter) async {
        await emitter.emit(
          MeterCaptureScreenState(
            step: MeterCaptureStep.edit,
            photoBytes: photo,
            creationStartedAt: at,
            capturedAt: at,
            recordedAt: at,
            recordedAtManuallySet: true,
            distanceKm: 1,
            duration: const Duration(minutes: 30),
            caloriesKcal: 100,
            averageSpeedKmh: 2,
          ),
        );
      });
      final save = _Save(
        result: SaveMeterCaptureResult(outcome: outcome, goalAutoUpdated: true),
      );
      final result = await OnSaveMeterCaptureDelegate(
        state: state,
        saveMeterCaptureUsecase: save,
      ).execute();

      expect(save.calls, 1);
      expect(save.lastRequest?.recordedAt, at);
      expect(save.lastRequest?.duration, const Duration(minutes: 30));
      expect(save.lastRequest?.recordedAtManuallySet, isTrue);
      expect(save.lastRequest?.photoBytes, photo);
      expect(state.state.saving, isFalse);
      if (outcome == SaveMeterCaptureOutcome.success) {
        expect(result?.goalAutoUpdated, isTrue);
        expect(state.state.photoBytes, isNull);
      } else {
        expect(result, isNull);
        expect(state.state.photoBytes, photo);
        expect(state.state.recordedAt, at);
        expect(state.state.duration, const Duration(minutes: 30));
        expect(
          state.state.saveError,
          outcome == SaveMeterCaptureOutcome.saveFailed,
        );
      }
    });
  }

  test('保存中の再実行を拒否し例外後には入力を保持して再試行できる', () async {
    final at = DateTime(2026, 11, 8, 12);
    await state.updateWithLock((_, emitter) async {
      await emitter.emit(
        MeterCaptureScreenState(
          step: MeterCaptureStep.edit,
          photoBytes: Uint8List.fromList([1]),
          creationStartedAt: at,
          capturedAt: at,
          recordedAt: at,
          distanceKm: 1,
          duration: const Duration(minutes: 30),
          caloriesKcal: 100,
          averageSpeedKmh: 2,
        ),
      );
    });
    final completion = Completer<SaveMeterCaptureResult>();
    final save = _Save(pending: completion.future);
    final delegate = OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: save,
    );
    final first = delegate.execute();
    // ロック取得後の呼び出しで、保存中のガードを観測する。
    final second = await delegate.execute();
    expect(second, isNull);
    expect(save.calls, 1);
    expect(state.state.saving, isTrue);
    completion.completeError(StateError('save failed'));
    expect(await first, isNull);
    expect(state.state.saving, isFalse);
    expect(state.state.saveError, isTrue);
    expect(state.state.recordedAt, at);

    final retry = _Save();
    final result = await OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: retry,
    ).execute();
    expect(result, isNotNull);
    expect(retry.calls, 1);
    expect(state.state.saveError, isFalse);
  });

  test('canSubmit 未満の save は usecase を呼ばない', () async {
    final save = _Save();

    final success = await OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: save,
    ).execute();

    expect(success, isNull);
    expect(save.calls, 0);
  });

  test('撮影成功で読み取りし edit へ進む', () async {
    await readyCamera();
    final obtain = _Obtain(
      ObtainMeterPhotoSuccess(bytes: Uint8List.fromList(const [9, 9])),
    );
    final read = _Read(
      const ReadMeterPanelResult(
        values: MeterReadingValues(
          distanceKm: 3,
          duration: Duration(hours: 1),
          caloriesKcal: 200,
          averageSpeedKmh: 3,
        ),
        averageSpeedFromPanel: true,
      ),
    );

    await OnCapturePhotoDelegate(
      state: state,
      obtainMeterPhotoUsecase: obtain,
      readMeterPanelUsecase: read,
      evaluateOnDeviceLlmGuidanceUsecase: _Evaluate(),
      guidanceSession: OnDeviceLlmGuidanceSession(),
    ).execute();

    expect(read.calls, 1);
    expect(state.state.step, MeterCaptureStep.edit);
    expect(state.state.distanceKm, 3);
    expect(state.state.averageSpeedFromPanel, isTrue);
    expect(state.state.reading, isFalse);
    expect(state.state.creationStartedAt, isNotNull);
    expect(state.state.capturedAt, isNotNull);
    expect(state.state.recordedAt, state.state.capturedAt);
    expect(state.state.recordedAtManuallySet, isFalse);
  });

  test('未ダウンロードかつ未提示なら pending true', () async {
    final evaluate = _Evaluate(shouldShow: true);
    await OnReadMeterDelegate(
      state: state,
      readMeterPanelUsecase: _Read(
        const ReadMeterPanelResult(
          values: MeterReadingValues(),
          averageSpeedFromPanel: false,
        ),
      ),
      evaluateOnDeviceLlmGuidanceUsecase: evaluate,
      guidanceSession: OnDeviceLlmGuidanceSession(),
    ).execute(photoBytes: Uint8List(0));

    expect(evaluate.calls, 1);
    expect(state.state.pendingModelDownloadGuidance, isTrue);
    expect(state.state.step, MeterCaptureStep.edit);
    expect(state.state.reading, isFalse);
  });

  test('markPresented 済みなら pending false かつ評価しない', () async {
    final session = OnDeviceLlmGuidanceSession()..markPresented();
    final evaluate = _Evaluate(shouldShow: true);
    await OnReadMeterDelegate(
      state: state,
      readMeterPanelUsecase: _Read(
        const ReadMeterPanelResult(
          values: MeterReadingValues(),
          averageSpeedFromPanel: false,
        ),
      ),
      evaluateOnDeviceLlmGuidanceUsecase: evaluate,
      guidanceSession: session,
    ).execute(photoBytes: Uint8List(0));

    expect(evaluate.calls, 0);
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    expect(state.state.step, MeterCaptureStep.edit);
  });

  test('誘導判定は読み取りをブロックしない', () async {
    final evaluate = _Evaluate(
      shouldShow: true,
      delay: const Duration(milliseconds: 50),
    );
    final read = _Read(
      const ReadMeterPanelResult(
        values: MeterReadingValues(distanceKm: 1),
        averageSpeedFromPanel: false,
      ),
      delay: const Duration(milliseconds: 10),
    );
    final future = OnReadMeterDelegate(
      state: state,
      readMeterPanelUsecase: read,
      evaluateOnDeviceLlmGuidanceUsecase: evaluate,
      guidanceSession: OnDeviceLlmGuidanceSession(),
    ).execute(photoBytes: Uint8List(0));

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(state.state.reading, isFalse);
    expect(state.state.step, MeterCaptureStep.edit);
    expect(state.state.distanceKm, 1);
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    expect(evaluate.calls, 1);
    expect(read.calls, 1);

    await future;
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(state.state.pendingModelDownloadGuidance, isTrue);
  });

  test('acknowledge 後は pending false かつ hasPresented', () async {
    state = MutableStateStream(
      const MeterCaptureScreenState(
        step: MeterCaptureStep.edit,
        pendingModelDownloadGuidance: true,
      ),
    );
    final session = OnDeviceLlmGuidanceSession();
    await OnAcknowledgeModelDownloadGuidanceDelegate(
      state: state,
      session: session,
    ).execute();
    expect(state.state.pendingModelDownloadGuidance, isFalse);
    expect(session.hasPresented, isTrue);
  });

  test('平均速度クリアは fromPanel を落として再計算する', () async {
    await state.updateWithLock((_, emitter) async {
      await emitter.emit(
        const MeterCaptureScreenState(
          step: MeterCaptureStep.edit,
          distanceKm: 30,
          duration: Duration(hours: 1),
          averageSpeedKmh: 9,
          averageSpeedFromPanel: true,
        ),
      );
    });

    await OnFieldChangedDelegate(state: state).updateAverageSpeed('');

    expect(state.state.averageSpeedKmh, 30);
    expect(state.state.averageSpeedFromPanel, isFalse);
    expect(state.state.averageSpeedUserEdited, isFalse);
  });

  test('canSubmitMeterCapture は必須と非負を見る', () {
    expect(
      canSubmitMeterCapture(
        distanceKm: 1,
        duration: const Duration(minutes: 1),
        averageSpeedKmh: 1,
        caloriesKcal: 1,
      ),
      isTrue,
    );
    expect(
      canSubmitMeterCapture(
        distanceKm: 1,
        duration: Duration.zero,
        averageSpeedKmh: 1,
        caloriesKcal: 1,
      ),
      isFalse,
    );
    expect(
      canSubmitMeterCapture(
        distanceKm: null,
        duration: const Duration(minutes: 1),
        averageSpeedKmh: 1,
        caloriesKcal: 1,
      ),
      isFalse,
    );
  });

  test('StateToEntity は未設定を空文字にする', () {
    const delegate = MeterCaptureStateToEntityDelegate();
    final empty = delegate.execute(MeterCaptureScreenState.initial);
    expect(empty.distanceText, '');
    expect(empty.hoursText, '');
    expect(empty.recordedAtText, '');
    expect(empty.pendingModelDownloadGuidance, isFalse);

    final filled = delegate.execute(
      MeterCaptureScreenState(
        step: MeterCaptureStep.edit,
        distanceKm: 1.5,
        duration: const Duration(hours: 1, minutes: 2, seconds: 3),
        averageSpeedKmh: 2,
        caloriesKcal: 100,
        recordedAt: DateTime(2026, 11, 8, 12),
        pendingModelDownloadGuidance: true,
      ),
    );
    expect(filled.distanceText, '1.5');
    expect(filled.hoursText, '1');
    expect(filled.minutesText, '2');
    expect(filled.secondsText, '3');
    expect(filled.averageSpeedText, '2.0');
    expect(filled.caloriesText, '100.0');
    expect(filled.recordedAtText, DateTime(2026, 11, 8, 12).toIso8601String());
    expect(filled.pendingModelDownloadGuidance, isTrue);
  });

  test('StateToEntity は UTC の記録日時をローカル時刻に変換する', () {
    final recordedAt = DateTime.utc(2026, 11, 8, 3);
    final entity = const MeterCaptureStateToEntityDelegate().execute(
      MeterCaptureScreenState(
        step: MeterCaptureStep.edit,
        recordedAt: recordedAt,
      ),
    );
    expect(entity.recordedAtText, recordedAt.toLocal().toIso8601String());
  });
}
