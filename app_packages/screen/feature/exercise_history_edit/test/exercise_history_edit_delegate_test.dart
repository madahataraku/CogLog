import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/can_submit_exercise_history_edit.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/obtain_and_read_edit_photo.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/on_field_changed_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/on_initialize_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/on_save_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/state/exercise_history_edit_screen_state.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_update_exercise_history/usecase_update_exercise_history.dart';

ExerciseHistory _history({required String id}) {
  final at = DateTime(2026, 11, 5, 12, 30);
  return ExerciseHistory(
    id: id,
    savedAt: at,
    creationStartedAt: at,
    capturedAt: at,
    recordedAt: at,
    recordedAtManuallySet: false,
    distanceKm: 1.25,
    duration: const Duration(minutes: 30),
    caloriesKcal: 12.34,
    averageSpeedKmh: 2.5,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
    healthWorkoutId: 'health-1',
  );
}

final class _LoadDetail implements LoadExerciseHistoryDetailUsecase {
  _LoadDetail(this.result);

  final LoadExerciseHistoryDetailResult result;

  @override
  Future<LoadExerciseHistoryDetailResult> execute(
    LoadExerciseHistoryDetailRequest request,
  ) async => result;
}

final class _Update implements UpdateExerciseHistoryUsecase {
  UpdateExerciseHistoryRequest? last;
  UpdateExerciseHistoryResult result = const UpdateExerciseHistoryResult(
    outcome: UpdateExerciseHistoryOutcome.success,
    recordedLocalDayChanged: false,
  );

  @override
  Future<UpdateExerciseHistoryResult> execute(
    UpdateExerciseHistoryRequest request,
  ) async {
    last = request;
    return result;
  }
}

final class _Obtain implements ObtainMeterPhotoUsecase {
  _Obtain(this.result);

  final ObtainMeterPhotoResult result;

  @override
  Future<ObtainMeterPhotoResult> execute(
    ObtainMeterPhotoRequest request,
  ) async => result;
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

final class _Nav implements ScreenNavigation {
  Object? poppedResult;
  var popCount = 0;
  var popWithResultCount = 0;

  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  Future<ExerciseHistoryEditPopResult?> openExerciseHistoryEditAndWait({
    required String id,
  }) async => null;

  @override
  void openAppSettings() {}

  @override
  Future<void> openAchievements() async {}

  @override
  void openDebug() {}

  @override
  void openNotificationSettings() {}

  @override
  void openOssLicenses() {}

  @override
  void openOssLicenseDetail({required String packageName}) {}

  @override
  void pop() {
    popCount += 1;
  }

  @override
  void popWithResult<T extends Object?>(T result) {
    popWithResultCount += 1;
    poppedResult = result;
  }

  @override
  void goToHomeTab() {}
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

  test('初期化で詳細をフィールドへ載せる', () async {
    const id = '11111111-1111-4111-8111-111111111111';
    final history = _history(id: id);
    await OnInitializeDelegate(
      state: state,
      loadDetailUsecase: _LoadDetail(
        LoadExerciseHistoryDetailSuccess(
          history: history,
          photoAbsolutePath: '/tmp/photo.jpg',
        ),
      ),
    ).execute(id: id);

    expect(state.state.loading, isFalse);
    expect(state.state.distanceKm, 1.25);
    expect(state.state.duration, const Duration(minutes: 30));
    expect(state.state.caloriesKcal, 12.34);
    expect(state.state.averageSpeedKmh, 2.5);
    expect(state.state.previousHealthWorkoutId, 'health-1');
    expect(state.state.photoPath, '/tmp/photo.jpg');
    expect(state.state.dirty, isFalse);
    expect(state.state.recordedAtManuallySet, isFalse);
    expect(state.state.fieldsSyncGeneration, greaterThan(0));
  });

  test('距離変更で平均速度を再計算し dirty になる', () async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          distanceKm: 1,
          duration: const Duration(hours: 1),
          averageSpeedKmh: 1,
          caloriesKcal: 1,
          recordedAt: DateTime(2026, 11, 5),
          creationStartedAt: DateTime(2026, 11, 5),
          capturedAt: DateTime(2026, 11, 5),
        ),
      );
    });
    await OnFieldChangedDelegate(state: state).updateDistance('30');
    expect(state.state.distanceKm, 30);
    expect(state.state.averageSpeedKmh, 30);
    expect(state.state.dirty, isTrue);
  });

  test('運動した日時の変更で dirty になり距離変更後も維持する', () async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          distanceKm: 1,
          duration: const Duration(hours: 1),
          averageSpeedKmh: 1,
          caloriesKcal: 1,
          recordedAt: DateTime(2026, 11, 5),
          creationStartedAt: DateTime(2026, 11, 5),
          capturedAt: DateTime(2026, 11, 5),
        ),
      );
    });
    final fields = OnFieldChangedDelegate(state: state);
    final next = DateTime(2026, 11, 8, 15, 30);
    await fields.updateRecordedAt(next);
    expect(state.state.recordedAt, next);
    expect(state.state.recordedAtManuallySet, isTrue);
    expect(state.state.recordedAtInvalid, isFalse);
    expect(state.state.dirty, isTrue);

    await fields.updateDistance('2');
    expect(state.state.distanceKm, 2);
    expect(state.state.distanceInvalid, isFalse);
    expect(state.state.recordedAt, next);
  });

  test('未変更では保存しない', () async {
    final nav = _Nav();
    final update = _Update();
    final at = DateTime(2026, 11, 5, 12);
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          id: 'id',
          dirty: false,
          distanceKm: 1,
          duration: const Duration(minutes: 30),
          averageSpeedKmh: 2,
          caloriesKcal: 10,
          recordedAt: at,
          creationStartedAt: at,
          capturedAt: at,
        ),
      );
    });

    await OnSaveDelegate(
      state: state,
      updateUsecase: update,
      navigation: nav,
    ).execute();

    expect(update.last, isNull);
    expect(nav.popWithResultCount, 0);
  });

  test('保存成功で PopResult を返す', () async {
    final nav = _Nav();
    final update = _Update();
    final at = DateTime(2026, 11, 5, 12);
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          id: 'id',
          dirty: true,
          distanceKm: 1,
          duration: const Duration(minutes: 30),
          averageSpeedKmh: 2,
          caloriesKcal: 10,
          recordedAt: at,
          creationStartedAt: at,
          capturedAt: at,
          previousHealthWorkoutId: null,
          photoBytes: Uint8List.fromList([1, 2, 3]),
        ),
      );
    });

    await OnSaveDelegate(
      state: state,
      updateUsecase: update,
      navigation: nav,
    ).execute();

    expect(update.last, isNotNull);
    expect(update.last!.photoBytes, isNotNull);
    expect(nav.popWithResultCount, 1);
    final result = nav.poppedResult! as ExerciseHistoryEditPopResult;
    expect(result.saved, isTrue);
    expect(result.recordedLocalDayChanged, isFalse);
  });

  test('canSubmit は運動時間 0 で false', () {
    expect(
      canSubmitExerciseHistoryEdit(
        distanceKm: 1,
        duration: Duration.zero,
        averageSpeedKmh: 1,
        caloriesKcal: 1,
        recordedAt: DateTime(2026),
        creationStartedAt: DateTime(2026),
        capturedAt: DateTime(2026),
      ),
      isFalse,
    );
  });

  test('手変更なしの写真差し替えは運動した日時を撮影日時で決め直す', () async {
    final oldAt = DateTime(2026, 5, 1, 10);
    final newCapturedAt = DateTime(2026, 5, 2, 15);
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          recordedAt: oldAt,
          recordedAtManuallySet: false,
          creationStartedAt: oldAt,
          capturedAt: oldAt,
          distanceKm: 1,
          duration: const Duration(minutes: 10),
          caloriesKcal: 10,
          averageSpeedKmh: 6,
        ),
      );
    });

    await obtainAndReadEditPhoto(
      state: state,
      obtainMeterPhotoUsecase: _Obtain(
        ObtainMeterPhotoSuccess(
          bytes: Uint8List.fromList([1]),
          capturedAt: newCapturedAt,
        ),
      ),
      readMeterPanelUsecase: _Read(),
      source: ObtainMeterPhotoSource.library,
    );

    expect(state.state.recordedAt, newCapturedAt);
    expect(state.state.recordedAtManuallySet, isFalse);
    expect(state.state.capturedAt, newCapturedAt);
    expect(state.state.fieldsSyncGeneration, greaterThan(0));
  });

  test('手変更ありの写真差し替えは運動した日時を維持する', () async {
    final oldAt = DateTime(2026, 5, 1, 10);
    final newCapturedAt = DateTime(2026, 5, 2, 15);
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          recordedAt: oldAt,
          recordedAtManuallySet: true,
          creationStartedAt: oldAt,
          capturedAt: oldAt,
          distanceKm: 1,
          duration: const Duration(minutes: 10),
          caloriesKcal: 10,
          averageSpeedKmh: 6,
        ),
      );
    });

    await obtainAndReadEditPhoto(
      state: state,
      obtainMeterPhotoUsecase: _Obtain(
        ObtainMeterPhotoSuccess(
          bytes: Uint8List.fromList([1]),
          capturedAt: newCapturedAt,
        ),
      ),
      readMeterPanelUsecase: _Read(),
      source: ObtainMeterPhotoSource.camera,
    );

    expect(state.state.recordedAt, oldAt);
    expect(state.state.recordedAtManuallySet, isTrue);
    expect(state.state.capturedAt, newCapturedAt);
  });
}
