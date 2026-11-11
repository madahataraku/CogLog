import 'dart:convert';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history_detail/src/viewmodel/delegate/exercise_history_detail_state_to_entity_delegate.dart';
import 'package:screen_feature_exercise_history_detail/src/viewmodel/delegate/on_initialize_delegate.dart';
import 'package:screen_feature_exercise_history_detail/src/viewmodel/delegate/on_page_changed_delegate.dart';
import 'package:screen_feature_exercise_history_detail/src/viewmodel/state/exercise_history_detail_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day/usecase_load_exercise_histories_for_same_recorded_day.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

ExerciseHistory _history({required String id, bool edited = false}) {
  final at = DateTime(2026, 11, 5, 12, 30);
  return ExerciseHistory(
    id: id,
    savedAt: at,
    creationStartedAt: at,
    capturedAt: at,
    recordedAt: at,
    recordedAtManuallySet: edited,
    distanceKm: 1.25,
    duration: const Duration(minutes: 30),
    caloriesKcal: 12.34,
    averageSpeedKmh: 2.5,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
  );
}

final class _LoadDetail implements LoadExerciseHistoryDetailUsecase {
  _LoadDetail(this.resultOrById, {this.failIds = const {}});

  final Object resultOrById;
  final Set<String> failIds;
  var calls = 0;
  final requestedIds = <String>[];

  @override
  Future<LoadExerciseHistoryDetailResult> execute(
    LoadExerciseHistoryDetailRequest request,
  ) async {
    calls += 1;
    requestedIds.add(request.id);
    if (failIds.contains(request.id)) {
      throw StateError('detail fail');
    }
    if (resultOrById is LoadExerciseHistoryDetailResult) {
      return resultOrById as LoadExerciseHistoryDetailResult;
    }
    final byId = resultOrById as Map<String, LoadExerciseHistoryDetailResult>;
    return byId[request.id]!;
  }
}

/// 最初の `a` 要求だけ遅延失敗し、続く `a` は成功する。
final class _RaceLoadDetail implements LoadExerciseHistoryDetailUsecase {
  _RaceLoadDetail({required this.historyA, required this.historyB});

  final ExerciseHistory historyA;
  final ExerciseHistory historyB;
  var aCalls = 0;

  @override
  Future<LoadExerciseHistoryDetailResult> execute(
    LoadExerciseHistoryDetailRequest request,
  ) async {
    if (request.id == 'b') {
      return LoadExerciseHistoryDetailSuccess(
        history: historyB,
        photoAbsolutePath: null,
      );
    }
    aCalls += 1;
    if (aCalls == 1) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      throw StateError('stale a fail');
    }
    return LoadExerciseHistoryDetailSuccess(
      history: historyA,
      photoAbsolutePath: null,
    );
  }
}

final class _LoadSameDay
    implements LoadExerciseHistoriesForSameRecordedDayUsecase {
  _LoadSameDay(this.result, {this.throwError = false});

  final LoadExerciseHistoriesForSameRecordedDayResult result;
  final bool throwError;
  var calls = 0;

  @override
  Future<LoadExerciseHistoriesForSameRecordedDayResult> execute(
    LoadExerciseHistoriesForSameRecordedDayRequest request,
  ) async {
    calls += 1;
    if (throwError) {
      throw StateError('same day fail');
    }
    return result;
  }
}

void main() {
  late MutableStateStream<ExerciseHistoryDetailScreenState> state;

  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    state = MutableStateStream(
      ExerciseHistoryDetailScreenState.initial(id: 'id'),
    );
  });

  tearDown(() async {
    await state.close();
    LocalizeStringDelegate.resetDelegateForTest();
  });

  test('不在は missing になる', () async {
    await OnInitializeDelegate(
      state: state,
      loadDetailUsecase: _LoadDetail(const LoadExerciseHistoryDetailNotFound()),
      loadSameDayUsecase: _LoadSameDay(
        const LoadExerciseHistoriesForSameRecordedDayNotFound(),
      ),
    ).execute(id: 'missing');

    expect(state.state.missing, isTrue);
    expect(state.state.history, isNull);
    expect(state.state.loading, isFalse);
    expect(state.state.sameDayIds, isEmpty);
  });

  test('写真無し成功は path null、同一日成功で ids を載せる', () async {
    final history = _history(id: 'a');
    await OnInitializeDelegate(
      state: state,
      loadDetailUsecase: _LoadDetail(
        LoadExerciseHistoryDetailSuccess(
          history: history,
          photoAbsolutePath: null,
        ),
      ),
      loadSameDayUsecase: _LoadSameDay(
        const LoadExerciseHistoriesForSameRecordedDaySuccess(
          ids: ['b', 'a', 'c'],
          initialIndex: 1,
        ),
      ),
    ).execute(id: 'a');

    expect(state.state.history, history);
    expect(state.state.photoAbsolutePath, isNull);
    expect(state.state.missing, isFalse);
    expect(state.state.sameDayIds, ['b', 'a', 'c']);
    expect(state.state.pageIndex, 1);
  });

  test('同一日 NotFound は単件フォールバック', () async {
    final history = _history(id: 'a');
    await OnInitializeDelegate(
      state: state,
      loadDetailUsecase: _LoadDetail(
        LoadExerciseHistoryDetailSuccess(
          history: history,
          photoAbsolutePath: null,
        ),
      ),
      loadSameDayUsecase: _LoadSameDay(
        const LoadExerciseHistoriesForSameRecordedDayNotFound(),
      ),
    ).execute(id: 'a');

    expect(state.state.sameDayIds, ['a']);
    expect(state.state.pageIndex, 0);
  });

  test('同一日失敗は単件フォールバック', () async {
    final history = _history(id: 'a');
    await OnInitializeDelegate(
      state: state,
      loadDetailUsecase: _LoadDetail(
        LoadExerciseHistoryDetailSuccess(
          history: history,
          photoAbsolutePath: null,
        ),
      ),
      loadSameDayUsecase: _LoadSameDay(
        const LoadExerciseHistoriesForSameRecordedDaySuccess(
          ids: ['a'],
          initialIndex: 0,
        ),
        throwError: true,
      ),
    ).execute(id: 'a');

    expect(state.state.sameDayIds, ['a']);
    expect(state.state.pageIndex, 0);
    expect(state.state.error, isNull);
  });

  test('ページめくり失敗でも pageIndex を維持する', () async {
    final historyA = _history(id: 'a');
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          id: 'a',
          sameDayIds: const ['a', 'b'],
          pageIndex: 0,
          history: historyA,
          loading: false,
        ),
      );
    });

    final loadDetail = _LoadDetail(
      {
        'a': LoadExerciseHistoryDetailSuccess(
          history: historyA,
          photoAbsolutePath: null,
        ),
      },
      failIds: {'b'},
    );

    await OnPageChangedDelegate(
      state: state,
      loadDetailUsecase: loadDetail,
    ).execute(index: 1);

    expect(state.state.pageIndex, 1);
    expect(state.state.id, 'b');
    expect(state.state.pageLoading, isFalse);
    expect(state.state.error, isNotNull);
    expect(state.state.history, isNull);
  });

  test('同一 ID への再遷移では古い失敗結果を捨てる', () async {
    final historyA = _history(id: 'a');
    final historyB = _history(id: 'b');
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          id: 'a',
          sameDayIds: const ['a', 'b'],
          pageIndex: 0,
          history: historyA,
          loading: false,
        ),
      );
    });

    final loadDetail = _RaceLoadDetail(historyA: historyA, historyB: historyB);
    final delegate = OnPageChangedDelegate(
      state: state,
      loadDetailUsecase: loadDetail,
    );

    final firstA = delegate.execute(index: 0);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await delegate.execute(index: 1);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await delegate.execute(index: 0);
    await firstA;

    expect(state.state.id, 'a');
    expect(state.state.pageIndex, 0);
    expect(state.state.pageLoading, isFalse);
    expect(state.state.history, historyA);
    expect(state.state.error, isNull);
  });

  test('複数件は showPagePosition、1 件は非表示', () {
    const delegate = ExerciseHistoryDetailStateToEntityDelegate();
    final multi = delegate.execute(
      ExerciseHistoryDetailScreenState(
        id: 'a',
        sameDayIds: const ['b', 'a', 'c'],
        pageIndex: 1,
        pageLoading: false,
        detailLoadGeneration: 0,
        loading: false,
        history: _history(id: 'a', edited: true),
        photoAbsolutePath: null,
        missing: false,
        error: null,
      ),
    );
    expect(multi.showPagePosition, isTrue);
    expect(multi.pageCurrent, 2);
    expect(multi.pageTotal, 3);
    expect(multi.recordedAtEditedSuffix, isNotEmpty);
    expect(multi.showPhoto, isFalse);
    expect(multi.showPhotoError, isTrue);
    expect(multi.caloriesText, contains('12.3'));
    expect(multi.averageSpeedText, contains('2.5'));

    final single = delegate.execute(
      ExerciseHistoryDetailScreenState(
        id: 'a',
        sameDayIds: const ['a'],
        pageIndex: 0,
        pageLoading: false,
        detailLoadGeneration: 0,
        loading: false,
        history: _history(id: 'a'),
        photoAbsolutePath: null,
        missing: false,
        error: null,
      ),
    );
    expect(single.showPagePosition, isFalse);
    expect(single.pageCurrent, 1);
    expect(single.pageTotal, 1);
  });

  test('missing entity は showMissing', () {
    const delegate = ExerciseHistoryDetailStateToEntityDelegate();
    final entity = delegate.execute(
      const ExerciseHistoryDetailScreenState(
        id: 'x',
        sameDayIds: [],
        pageIndex: 0,
        pageLoading: false,
        detailLoadGeneration: 0,
        loading: false,
        history: null,
        photoAbsolutePath: null,
        missing: true,
        error: null,
      ),
    );
    expect(entity.showMissing, isTrue);
  });

  test('page_position 文言が StringsTestHelper から取れる', () {
    final ja = jsonDecode(StringsTestHelper.ja) as Map<String, Object?>;
    expect(
      ja['screen_feature_exercise_history_detail_page_position'],
      isNotNull,
    );
  });
}
