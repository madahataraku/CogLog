import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/can_submit_meter_capture.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/meter_capture_state_to_entity_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/on_back_to_step1_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/on_capture_photo_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/on_field_changed_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/delegate/on_save_meter_capture_delegate.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_camera_ui.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_screen_state.dart';
import 'package:screen_feature_meter_capture/src/viewmodel/state/meter_capture_step.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';

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

final class _Read implements ReadMeterPanelUsecase {
  _Read(this.result);

  final ReadMeterPanelResult result;
  var calls = 0;

  @override
  Future<ReadMeterPanelResult> execute(ReadMeterPanelRequest request) async {
    calls += 1;
    return result;
  }
}

final class _Save implements SaveMeterCaptureUsecase {
  _Save({this.result});

  final SaveMeterCaptureResult? result;
  var calls = 0;

  @override
  Future<SaveMeterCaptureResult> execute(
    SaveMeterCaptureRequest request,
  ) async {
    calls += 1;
    return result ??
        const SaveMeterCaptureResult(outcome: SaveMeterCaptureOutcome.success);
  }
}

final class _Nav implements ScreenNavigation {
  var homeCalls = 0;

  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  void openAppSettings() {}

  @override
  void openDebug() {}

  @override
  void pop() {}

  @override
  void goToHomeTab() {
    homeCalls += 1;
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
    ).execute();

    expect(obtain.calls, 1);
    expect(obtain.lastSource, ObtainMeterPhotoSource.camera);
    expect(read.calls, 0);
    expect(state.state.step, MeterCaptureStep.photo);
    expect(state.state.photoBytes, isNull);
    expect(state.state.captureError, isTrue);
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

  test('D4: save ok で goToHomeTab 1 回', () async {
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
    final nav = _Nav();

    await OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: save,
      navigation: nav,
    ).execute();

    expect(save.calls, 1);
    expect(nav.homeCalls, 1);
    expect(state.state.saveError, isFalse);
    expect(state.state.saving, isFalse);
    expect(state.state.step, MeterCaptureStep.photo);
    expect(state.state.photoBytes, isNull);
  });

  test('saveFailed は saveError を立てホームへ行かない', () async {
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
    final nav = _Nav();

    await OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: save,
      navigation: nav,
    ).execute();

    expect(nav.homeCalls, 0);
    expect(state.state.saveError, isTrue);
    expect(state.state.step, MeterCaptureStep.edit);
  });

  test('canSubmit 未満の save は usecase を呼ばない', () async {
    final save = _Save();
    final nav = _Nav();

    await OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: save,
      navigation: nav,
    ).execute();

    expect(save.calls, 0);
    expect(nav.homeCalls, 0);
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

    final filled = delegate.execute(
      MeterCaptureScreenState(
        step: MeterCaptureStep.edit,
        distanceKm: 1.5,
        duration: const Duration(hours: 1, minutes: 2, seconds: 3),
        averageSpeedKmh: 2,
        caloriesKcal: 100,
        recordedAt: DateTime(2026, 11, 8, 12),
      ),
    );
    expect(filled.distanceText, '1.5');
    expect(filled.hoursText, '1');
    expect(filled.minutesText, '2');
    expect(filled.secondsText, '3');
    expect(filled.averageSpeedText, '2.0');
    expect(filled.caloriesText, '100.0');
    expect(filled.recordedAtText, DateTime(2026, 11, 8, 12).toIso8601String());
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
