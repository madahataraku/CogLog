import 'dart:async';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/delegate/exercise_history_state_to_entity_delegate.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/delegate/on_initialize_delegate.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/delegate/on_load_more_delegate.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/delegate/on_select_month_delegate.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/state/exercise_history_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';

ExerciseHistory _history({
  required String id,
  required DateTime creationStartedAt,
  double calories = 10,
  double distance = 1,
}) => ExerciseHistory(
  id: id,
  savedAt: creationStartedAt,
  creationStartedAt: creationStartedAt,
  capturedAt: creationStartedAt,
  recordedAt: creationStartedAt,
  recordedAtManuallySet: false,
  distanceKm: distance,
  duration: const Duration(minutes: 30),
  caloriesKcal: calories,
  averageSpeedKmh: 2,
  photoRelativePath: 'exercise_histories/$id/meter.jpg',
);

final class _LoadPage implements LoadExerciseHistoryPageUsecase {
  _LoadPage(this._handler);

  final Future<LoadExerciseHistoryPageResult> Function(
    LoadExerciseHistoryPageRequest request,
  )
  _handler;
  var calls = 0;
  LoadExerciseHistoryPageRequest? lastRequest;

  @override
  Future<LoadExerciseHistoryPageResult> execute(
    LoadExerciseHistoryPageRequest request,
  ) async {
    calls += 1;
    lastRequest = request;
    return _handler(request);
  }
}

void main() {
  late MutableStateStream<ExerciseHistoryScreenState> state;

  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    state = MutableStateStream(
      ExerciseHistoryScreenState.initial(year: 2026, month: 11),
    );
  });

  tearDown(() async {
    await state.close();
    LocalizeStringDelegate.resetDelegateForTest();
  });

  test('初期化で当月を読み、items を入れる', () async {
    final item = _history(id: 'a', creationStartedAt: DateTime(2026, 11, 5));
    final load = _LoadPage(
      (_) async => LoadExerciseHistoryPageResult(items: [item], hasMore: false),
    );
    await OnInitializeDelegate(
      state: state,
      loadPageUsecase: load,
      now: DateTime(2026, 11, 8),
    ).execute();

    expect(state.state.year, 2026);
    expect(state.state.month, 11);
    expect(state.state.loading, isFalse);
    expect(state.state.items, [item]);
    expect(state.state.hasMore, isFalse);
    expect(load.calls, 1);
    expect(load.lastRequest?.offset, 0);
  });

  test('loadMore 失敗でも items を残す', () async {
    final first = List.generate(
      30,
      (i) => _history(
        id: 'id-$i',
        creationStartedAt: DateTime(2026, 11, 1).add(Duration(minutes: i)),
      ),
    );
    state = MutableStateStream(
      ExerciseHistoryScreenState(
        year: 2026,
        month: 11,
        items: first,
        loading: false,
        refreshing: false,
        loadingMore: false,
        hasMore: true,
        loadError: null,
        loadMoreError: null,
      ),
    );
    final load = _LoadPage((_) async => throw StateError('fail'));
    await OnLoadMoreDelegate(state: state, loadPageUsecase: load).execute();

    expect(state.state.items, first);
    expect(state.state.loadingMore, isFalse);
    expect(state.state.loadMoreError, isA<StateError>());
  });

  test('loadMore 完了時に offset が変わっていれば追記しない', () async {
    final first = List.generate(
      30,
      (i) => _history(
        id: 'id-$i',
        creationStartedAt: DateTime(2026, 11, 1).add(Duration(minutes: i)),
      ),
    );
    final refreshed = [
      _history(id: 'refreshed', creationStartedAt: DateTime(2026, 11, 2)),
    ];
    state = MutableStateStream(
      ExerciseHistoryScreenState(
        year: 2026,
        month: 11,
        items: first,
        loading: false,
        refreshing: false,
        loadingMore: false,
        hasMore: true,
        loadError: null,
        loadMoreError: null,
      ),
    );
    final gate = Completer<void>();
    final load = _LoadPage((_) async {
      await gate.future;
      return LoadExerciseHistoryPageResult(
        items: [
          _history(id: 'page2', creationStartedAt: DateTime(2026, 11, 3)),
        ],
        hasMore: false,
      );
    });
    final pending = OnLoadMoreDelegate(
      state: state,
      loadPageUsecase: load,
    ).execute();
    await Future<void>.delayed(Duration.zero);
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(items: refreshed, hasMore: false, loadingMore: true),
      );
    });
    gate.complete();
    await pending;

    expect(state.state.items, refreshed);
    expect(state.state.loadingMore, isFalse);
    expect(state.state.items.any((e) => e.id == 'page2'), isFalse);
  });

  test('月切替で items をクリアして読み直す', () async {
    state = MutableStateStream(
      ExerciseHistoryScreenState(
        year: 2026,
        month: 11,
        items: [_history(id: 'old', creationStartedAt: DateTime(2026, 11, 1))],
        loading: false,
        refreshing: false,
        loadingMore: false,
        hasMore: false,
        loadError: null,
        loadMoreError: null,
      ),
    );
    final next = _history(id: 'new', creationStartedAt: DateTime(2026, 10, 1));
    final load = _LoadPage(
      (_) async => LoadExerciseHistoryPageResult(items: [next], hasMore: false),
    );
    await OnSelectMonthDelegate(
      state: state,
      loadPageUsecase: load,
    ).execute(year: 2026, month: 10);

    expect(state.state.year, 2026);
    expect(state.state.month, 10);
    expect(state.state.items, [next]);
    expect(load.lastRequest?.month, 10);
  });

  test('state_to_entity は空と月ラベルと書式を出す', () {
    const delegate = ExerciseHistoryStateToEntityDelegate();
    final empty = delegate.execute(
      ExerciseHistoryScreenState.initial(year: 2026, month: 11),
    );
    expect(empty.showEmpty, isTrue);
    expect(empty.monthLabel, contains('2026'));
    expect(empty.monthLabel, contains('11'));

    final withItem = delegate.execute(
      ExerciseHistoryScreenState(
        year: 2026,
        month: 11,
        items: [
          _history(
            id: 'a',
            creationStartedAt: DateTime(2026, 11, 5, 12, 30),
            calories: 12.34,
            distance: 1.25,
          ),
        ],
        loading: false,
        refreshing: false,
        loadingMore: false,
        hasMore: false,
        loadError: null,
        loadMoreError: null,
      ),
    );
    expect(withItem.showEmpty, isFalse);
    expect(withItem.items.single.caloriesText, '12.3');
    expect(withItem.items.single.distanceText, '1.3');
    expect(withItem.items.single.durationText, '0h30m');
    expect(withItem.items.single.createdAtText, '2026-11-05 12:30');
  });
}
