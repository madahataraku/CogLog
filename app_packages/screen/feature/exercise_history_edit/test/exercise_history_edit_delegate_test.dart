import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/can_submit_exercise_history_edit.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/on_field_changed_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/on_initialize_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/delegate/on_save_delegate.dart';
import 'package:screen_feature_exercise_history_edit/src/viewmodel/state/exercise_history_edit_screen_state.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';
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

  test('保存成功で PopResult を返す', () async {
    final nav = _Nav();
    final update = _Update();
    final at = DateTime(2026, 11, 5, 12);
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          id: 'id',
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
}
