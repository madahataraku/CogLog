import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history_detail/src/viewmodel/delegate/on_delete_delegate.dart';
import 'package:screen_feature_exercise_history_detail/src/viewmodel/delegate/on_edit_delegate.dart';
import 'package:screen_feature_exercise_history_detail/src/viewmodel/state/exercise_history_detail_screen_state.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_delete_exercise_history/usecase_delete_exercise_history.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day/usecase_load_exercise_histories_for_same_recorded_day.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

ExerciseHistory _history({required String id, String? healthWorkoutId}) {
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
    healthWorkoutId: healthWorkoutId,
  );
}

final class _LoadDetail implements LoadExerciseHistoryDetailUsecase {
  _LoadDetail(this.byId);

  final Map<String, LoadExerciseHistoryDetailResult> byId;
  final requestedIds = <String>[];

  @override
  Future<LoadExerciseHistoryDetailResult> execute(
    LoadExerciseHistoryDetailRequest request,
  ) async {
    requestedIds.add(request.id);
    return byId[request.id]!;
  }
}

final class _LoadSameDay
    implements LoadExerciseHistoriesForSameRecordedDayUsecase {
  _LoadSameDay(this.result);

  final LoadExerciseHistoriesForSameRecordedDayResult result;

  @override
  Future<LoadExerciseHistoriesForSameRecordedDayResult> execute(
    LoadExerciseHistoriesForSameRecordedDayRequest request,
  ) async => result;
}

final class _Delete implements DeleteExerciseHistoryUsecase {
  DeleteExerciseHistoryRequest? last;
  DeleteExerciseHistoryOutcome outcome = DeleteExerciseHistoryOutcome.success;

  @override
  Future<DeleteExerciseHistoryResult> execute(
    DeleteExerciseHistoryRequest request,
  ) async {
    last = request;
    return DeleteExerciseHistoryResult(outcome: outcome);
  }
}

final class _Nav implements ScreenNavigation {
  ExerciseHistoryEditPopResult? editResult;
  String? editId;
  var popCount = 0;

  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  Future<ExerciseHistoryEditPopResult?> openExerciseHistoryEditAndWait({
    required String id,
  }) async {
    editId = id;
    return editResult;
  }

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
  void popWithResult<T extends Object?>(T result) {}

  @override
  void goToHomeTab() {}
}

void main() {
  late MutableStateStream<ExerciseHistoryDetailScreenState> state;

  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    state = MutableStateStream(
      ExerciseHistoryDetailScreenState.initial(id: 'a'),
    );
  });

  tearDown(() async {
    await state.close();
    LocalizeStringDelegate.resetDelegateForTest();
  });

  test('削除成功で同一日残りが無ければ pop', () async {
    final history = _history(id: 'a', healthWorkoutId: 'h1');
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          history: history,
          sameDayIds: const ['a'],
          pageIndex: 0,
        ),
      );
    });
    final nav = _Nav();
    final delete = _Delete();
    await OnDeleteDelegate(
      state: state,
      deleteUsecase: delete,
      loadDetailUsecase: _LoadDetail({}),
      loadSameDayUsecase: _LoadSameDay(
        const LoadExerciseHistoriesForSameRecordedDayNotFound(),
      ),
      navigation: nav,
    ).execute();

    expect(delete.last?.id, 'a');
    expect(delete.last?.healthWorkoutId, 'h1');
    expect(nav.popCount, 1);
  });

  test('削除成功で同一日残りがあれば push せず再読込', () async {
    final historyA = _history(id: 'a');
    final historyB = _history(id: 'b');
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          history: historyA,
          sameDayIds: const ['a', 'b'],
          pageIndex: 0,
        ),
      );
    });
    final nav = _Nav();
    final detail = _LoadDetail({
      'b': LoadExerciseHistoryDetailSuccess(
        history: historyB,
        photoAbsolutePath: null,
      ),
    });
    await OnDeleteDelegate(
      state: state,
      deleteUsecase: _Delete(),
      loadDetailUsecase: detail,
      loadSameDayUsecase: _LoadSameDay(
        const LoadExerciseHistoriesForSameRecordedDaySuccess(
          ids: ['b'],
          initialIndex: 0,
        ),
      ),
      navigation: nav,
    ).execute();

    expect(nav.popCount, 0);
    expect(detail.requestedIds, contains('b'));
    expect(state.state.history?.id, 'b');
  });

  test('編集保存で暦日変更ならカレンダーへ pop', () async {
    final history = _history(id: 'a');
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(history: history, sameDayIds: ['a']));
    });
    final nav = _Nav()
      ..editResult = const ExerciseHistoryEditPopResult(
        saved: true,
        recordedLocalDayChanged: true,
      );
    await OnEditDelegate(
      state: state,
      loadDetailUsecase: _LoadDetail({}),
      loadSameDayUsecase: _LoadSameDay(
        const LoadExerciseHistoriesForSameRecordedDayNotFound(),
      ),
      navigation: nav,
    ).execute();

    expect(nav.editId, 'a');
    expect(nav.popCount, 1);
  });

  test('編集保存で暦日不変なら再読込', () async {
    final history = _history(id: 'a');
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(history: history, sameDayIds: ['a']));
    });
    final nav = _Nav()
      ..editResult = const ExerciseHistoryEditPopResult(
        saved: true,
        recordedLocalDayChanged: false,
      );
    final detail = _LoadDetail({
      'a': LoadExerciseHistoryDetailSuccess(
        history: history,
        photoAbsolutePath: null,
      ),
    });
    await OnEditDelegate(
      state: state,
      loadDetailUsecase: detail,
      loadSameDayUsecase: _LoadSameDay(
        const LoadExerciseHistoriesForSameRecordedDaySuccess(
          ids: ['a'],
          initialIndex: 0,
        ),
      ),
      navigation: nav,
    ).execute();

    expect(nav.popCount, 0);
    expect(detail.requestedIds, contains('a'));
  });
}
