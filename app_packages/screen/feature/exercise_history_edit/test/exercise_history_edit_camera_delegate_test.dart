import 'dart:async';
import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/exercise_history_edit_state_to_entity_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/on_apply_edit_camera_status_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/on_cancel_edit_camera_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/on_capture_edit_camera_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/on_retake_photo_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/state/edit_camera_ui.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/state/exercise_history_edit_phase.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/state/exercise_history_edit_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

final class _ControlCamera implements ControlMeterInAppCameraUsecase {
  var startCount = 0;
  var stopCount = 0;

  @override
  Stream<MeterInAppCameraUiStatus> watch() => const Stream.empty();

  @override
  Future<void> start() async {
    startCount += 1;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }

  @override
  Widget buildPreview({Key? key}) => const SizedBox.shrink();
}

final class _Obtain implements ObtainMeterPhotoUsecase {
  _Obtain(this.result);

  final ObtainMeterPhotoResult result;
  var calls = 0;

  @override
  Future<ObtainMeterPhotoResult> execute(
    ObtainMeterPhotoRequest request,
  ) async {
    calls += 1;
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

final class _ThrowingObtain implements ObtainMeterPhotoUsecase {
  var calls = 0;

  @override
  Future<ObtainMeterPhotoResult> execute(
    ObtainMeterPhotoRequest request,
  ) async {
    calls += 1;
    throw Exception('capture failed');
  }
}

final class _Read implements ReadMeterPanelUsecase {
  @override
  Future<ReadMeterPanelResult> execute(ReadMeterPanelRequest request) async =>
      const ReadMeterPanelResult(
        values: MeterReadingValues(
          distanceKm: 3,
          duration: Duration(minutes: 20),
          caloriesKcal: 40,
        ),
        averageSpeedFromPanel: false,
      );
}

Future<void> _seedForm(
  MutableStateStream<ExerciseHistoryEditScreenState> state, {
  Uint8List? photoBytes,
  bool dirty = false,
}) async {
  final at = DateTime(2026, 5, 1, 10);
  await state.updateWithLock((current, emitter) async {
    await emitter.emit(
      current.copyWith(
        photoPath: 'old.jpg',
        photoBytes: photoBytes,
        recordedAt: at,
        capturedAt: at,
        creationStartedAt: at,
        distanceKm: 1,
        duration: const Duration(minutes: 10),
        caloriesKcal: 10,
        averageSpeedKmh: 6,
        dirty: dirty,
      ),
    );
  });
}

Future<void> _enterCameraReady(
  MutableStateStream<ExerciseHistoryEditScreenState> state,
) async {
  await state.updateWithLock((current, emitter) async {
    await emitter.emit(
      current.copyWith(
        phase: ExerciseHistoryEditPhase.camera,
        cameraUi: EditCameraUi.ready,
        cameraPreviewAspectRatio: 0.75,
      ),
    );
  });
}

void main() {
  late MutableStateStream<ExerciseHistoryEditScreenState> state;

  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    state = MutableStateStream(
      ExerciseHistoryEditScreenState.initial(id: 'id'),
    );
  });

  tearDown(() async {
    await state.close();
    LocalizeStringDelegate.resetDelegateForTest();
  });

  test('onRetake は phase=camera にし start を 1 回呼ぶ', () async {
    await _seedForm(state, dirty: true);
    final camera = _ControlCamera();
    final generation = state.state.photoSessionGeneration;

    await OnRetakePhotoDelegate(
      state: state,
      controlMeterInAppCameraUsecase: camera,
    ).execute();

    expect(
      state.state.phase,
      ExerciseHistoryEditPhase.camera,
      reason: '撮り直しは同一画面のカメラ phase に切り替える',
    );
    expect(state.state.cameraUi, EditCameraUi.starting, reason: '開始直後は初期化中');
    expect(camera.startCount, 1, reason: 'start は 1 回だけ');
    expect(
      state.state.photoSessionGeneration,
      generation,
      reason: 'カメラ入場では世代を進めない',
    );
    expect(state.state.dirty, isTrue, reason: '入場だけでは dirty を変えない');
    expect(state.state.photoPath, 'old.jpg', reason: '入場だけでは写真を変えない');
  });

  test('onCancelEditCamera は stop し form へ戻し値を変えない', () async {
    final bytes = Uint8List.fromList([1]);
    await _seedForm(state, photoBytes: bytes, dirty: true);
    final camera = _ControlCamera();
    await OnRetakePhotoDelegate(
      state: state,
      controlMeterInAppCameraUsecase: camera,
    ).execute();

    await OnCancelEditCameraDelegate(
      state: state,
      controlMeterInAppCameraUsecase: camera,
    ).execute();

    expect(
      state.state.phase,
      ExerciseHistoryEditPhase.form,
      reason: 'キャンセルは form に戻る',
    );
    expect(camera.stopCount, 1, reason: 'stop は 1 回');
    expect(state.state.dirty, isTrue, reason: 'dirty は不変');
    expect(state.state.photoBytes, bytes, reason: '写真は不変');
    expect(state.state.distanceKm, 1, reason: '計測値は不変');
  });

  test('onCapture Success は form へ戻り読み取り結果を載せる', () async {
    final bytes = Uint8List.fromList([9, 8, 7]);
    await _seedForm(state);
    await _enterCameraReady(state);
    final camera = _ControlCamera();
    final capturedAt = DateTime(2026, 5, 2, 15);

    await OnCaptureEditCameraDelegate(
      state: state,
      obtainMeterPhotoUsecase: _Obtain(
        ObtainMeterPhotoSuccess(bytes: bytes, capturedAt: capturedAt),
      ),
      readMeterPanelUsecase: _Read(),
      controlMeterInAppCameraUsecase: camera,
    ).execute();

    expect(
      state.state.phase,
      ExerciseHistoryEditPhase.form,
      reason: '撮影成功後は form',
    );
    expect(camera.stopCount, 1, reason: '成功時はカメラを止める');
    expect(state.state.photoBytes, bytes, reason: '確定写真を載せる');
    expect(state.state.reading, isFalse, reason: '読み取り完了後は reading を下ろす');
    expect(state.state.distanceKm, 3, reason: '読み取り距離を載せる');
    expect(state.state.duration, const Duration(minutes: 20), reason: '読み取り時間');
    expect(state.state.caloriesKcal, 40, reason: '読み取りカロリー');
    expect(state.state.dirty, isTrue, reason: '差し替え後は dirty');
    expect(state.state.cameraCapturing, isFalse, reason: '撮影フラグを下ろす');
  });

  test('onCapture Cancelled は camera のまま captureFailed', () async {
    await _seedForm(state);
    await _enterCameraReady(state);
    final camera = _ControlCamera();

    await OnCaptureEditCameraDelegate(
      state: state,
      obtainMeterPhotoUsecase: _Obtain(const ObtainMeterPhotoCancelled()),
      readMeterPanelUsecase: _Read(),
      controlMeterInAppCameraUsecase: camera,
    ).execute();

    expect(
      state.state.phase,
      ExerciseHistoryEditPhase.camera,
      reason: '取消ではカメラに留まる',
    );
    expect(state.state.cameraCaptureFailed, isTrue, reason: '失敗表示を立てる');
    expect(state.state.photoPath, 'old.jpg', reason: '写真は不変');
    expect(camera.stopCount, 0, reason: '取消ではカメラを止めない');
  });

  test('onCapture PermissionDenied は cameraUi=permissionDenied', () async {
    await _seedForm(state);
    await _enterCameraReady(state);

    await OnCaptureEditCameraDelegate(
      state: state,
      obtainMeterPhotoUsecase: _Obtain(
        const ObtainMeterPhotoPermissionDenied(MeterPhotoPermissionKind.camera),
      ),
      readMeterPanelUsecase: _Read(),
      controlMeterInAppCameraUsecase: _ControlCamera(),
    ).execute();

    expect(
      state.state.cameraUi,
      EditCameraUi.permissionDenied,
      reason: '権限拒否 UI にする',
    );
    expect(
      state.state.permissionDeniedKind,
      MeterPhotoPermissionKind.camera,
      reason: 'カメラ権限拒否を載せる',
    );
    expect(
      state.state.phase,
      ExerciseHistoryEditPhase.camera,
      reason: '権限拒否でもカメラ phase',
    );
  });

  test('status ready は cameraUi と aspectRatio を写す', () async {
    await _enterCameraReady(state);
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          cameraUi: EditCameraUi.starting,
          clearCameraPreviewAspectRatio: true,
        ),
      );
    });

    await OnApplyEditCameraStatusDelegate(state: state)
        .execute(const MeterInAppCameraUiReady(aspectRatio: 1.5));

    expect(state.state.cameraUi, EditCameraUi.ready, reason: 'ready を写す');
    expect(state.state.cameraPreviewAspectRatio, 1.5, reason: '縦横比を写す');
  });

  test('form 中の status は無視する', () async {
    await OnApplyEditCameraStatusDelegate(state: state)
        .execute(const MeterInAppCameraUiReady(aspectRatio: 1.5));

    expect(
      state.state.phase,
      ExerciseHistoryEditPhase.form,
      reason: 'phase 不変',
    );
    expect(state.state.cameraUi, EditCameraUi.idle, reason: 'form では写さない');
  });

  test('capturing 中の二重シャッターは obtain が 1 回', () async {
    await _seedForm(state);
    await _enterCameraReady(state);
    final pending = Completer<ObtainMeterPhotoResult>();
    final obtain = _DeferredObtain(pending);
    final delegate = OnCaptureEditCameraDelegate(
      state: state,
      obtainMeterPhotoUsecase: obtain,
      readMeterPanelUsecase: _Read(),
      controlMeterInAppCameraUsecase: _ControlCamera(),
    );

    final first = delegate.execute();
    await Future<void>.delayed(Duration.zero);
    expect(state.state.cameraCapturing, isTrue, reason: '1 回目で撮影中になる');
    expect(obtain.calls, 1, reason: '1 回目だけ obtain する');

    await delegate.execute();
    expect(obtain.calls, 1, reason: '撮影中の 2 回目は弾く');

    pending.complete(const ObtainMeterPhotoCancelled());
    await first;
  });

  test('obtain 例外は captureFailed で写真不変', () async {
    await _seedForm(state);
    await _enterCameraReady(state);
    final obtain = _ThrowingObtain();

    await OnCaptureEditCameraDelegate(
      state: state,
      obtainMeterPhotoUsecase: obtain,
      readMeterPanelUsecase: _Read(),
      controlMeterInAppCameraUsecase: _ControlCamera(),
    ).execute();

    expect(
      state.state.phase,
      ExerciseHistoryEditPhase.camera,
      reason: '例外でもカメラに留まる',
    );
    expect(state.state.cameraCapturing, isFalse, reason: '撮影中フラグを下ろす');
    expect(state.state.cameraCaptureFailed, isTrue, reason: '失敗表示を立てる');
    expect(state.state.photoPath, 'old.jpg', reason: '写真は不変');
    expect(obtain.calls, 1, reason: 'obtain は 1 回');
  });

  test('Entity は camera ready でシャッターを有効にする', () {
    final entity = const ExerciseHistoryEditStateToEntityDelegate().execute(
      ExerciseHistoryEditScreenState.initial(id: 'id').copyWith(
        phase: ExerciseHistoryEditPhase.camera,
        cameraUi: EditCameraUi.ready,
        cameraPreviewAspectRatio: 0.75,
      ),
    );
    expect(entity.showCameraPhase, isTrue, reason: 'カメラ phase を出す');
    expect(entity.cameraReady, isTrue, reason: 'ready');
    expect(entity.shutterEnabled, isTrue, reason: '撮影可能');
  });
}
