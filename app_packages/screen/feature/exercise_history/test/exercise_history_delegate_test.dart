import 'dart:convert';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/delegate/exercise_history_state_to_entity_delegate.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/delegate/on_cold_start_delegate.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/delegate/on_reload_selected_month_delegate.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/delegate/on_select_month_delegate.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/delegate/on_tap_day_delegate.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/state/exercise_history_screen_state.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';

ExerciseHistory _history({
  required String id,
  required DateTime recordedAt,
  DateTime? creationStartedAt,
}) {
  final created = creationStartedAt ?? recordedAt;
  return ExerciseHistory(
    id: id,
    savedAt: created,
    creationStartedAt: created,
    capturedAt: created,
    recordedAt: recordedAt,
    recordedAtManuallySet: false,
    distanceKm: 1,
    duration: const Duration(minutes: 30),
    caloriesKcal: 10,
    averageSpeedKmh: 2,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
  );
}

final class _LoadMonth implements LoadExerciseHistoryMonthUsecase {
  _LoadMonth(this._handler);

  final Future<LoadExerciseHistoryMonthResult> Function(
    LoadExerciseHistoryMonthRequest request,
  )
  _handler;
  var calls = 0;
  LoadExerciseHistoryMonthRequest? lastRequest;

  @override
  Future<LoadExerciseHistoryMonthResult> execute(
    LoadExerciseHistoryMonthRequest request,
  ) async {
    calls += 1;
    lastRequest = request;
    return _handler(request);
  }
}

final class _Nav implements ScreenNavigation {
  String? openedId;

  @override
  void openExerciseHistoryDetail({required String id}) {
    openedId = id;
  }

  @override
  void openAppSettings() {}

  @override
  void openAchievements() {}

  @override
  void openDebug() {}

  @override
  void openNotificationSettings() {}

  @override
  void openOssLicenses() {}

  @override
  void openOssLicenseDetail({required String packageName}) {}

  @override
  void pop() {}

  @override
  void goToHomeTab() {}
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

  test('ColdStart で当月を読み、items を入れる', () async {
    final item = _history(id: 'a', recordedAt: DateTime(2026, 11, 5));
    final load = _LoadMonth(
      (_) async => LoadExerciseHistoryMonthResult(items: [item]),
    );
    await OnColdStartDelegate(
      state: state,
      loadMonthUsecase: load,
      now: DateTime(2026, 11, 8),
    ).execute();

    expect(state.state.year, 2026);
    expect(state.state.month, 11);
    expect(state.state.loading, isFalse);
    expect(state.state.items, [item]);
    expect(state.state.reloadGeneration, 1);
    expect(load.calls, 1);
    expect(load.lastRequest?.year, 2026);
    expect(load.lastRequest?.month, 11);
  });

  test('ReloadSelectedMonth は year/month を変えず items を更新する', () async {
    final old = _history(id: 'old', recordedAt: DateTime(2026, 11, 1));
    final next = _history(id: 'new', recordedAt: DateTime(2026, 11, 2));
    state = MutableStateStream(
      ExerciseHistoryScreenState(
        year: 2026,
        month: 11,
        items: [old],
        loading: false,
        loadError: null,
        reloadGeneration: 3,
      ),
    );
    final load = _LoadMonth(
      (_) async => LoadExerciseHistoryMonthResult(items: [next]),
    );
    await OnReloadSelectedMonthDelegate(
      state: state,
      loadMonthUsecase: load,
    ).execute();

    expect(state.state.year, 2026);
    expect(state.state.month, 11);
    expect(state.state.items, [next]);
    expect(state.state.reloadGeneration, 4);
    expect(load.calls, 1);
  });

  test('月切替で items をクリアして読み直す', () async {
    state = MutableStateStream(
      ExerciseHistoryScreenState(
        year: 2026,
        month: 11,
        items: [_history(id: 'old', recordedAt: DateTime(2026, 11, 1))],
        loading: false,
        loadError: null,
        reloadGeneration: 1,
      ),
    );
    final next = _history(id: 'new', recordedAt: DateTime(2026, 10, 1));
    final load = _LoadMonth(
      (_) async => LoadExerciseHistoryMonthResult(items: [next]),
    );
    await OnSelectMonthDelegate(
      state: state,
      loadMonthUsecase: load,
    ).execute(year: 2026, month: 10);

    expect(state.state.year, 2026);
    expect(state.state.month, 10);
    expect(state.state.items, [next]);
    expect(load.lastRequest?.month, 10);
  });

  test('TapDay は作成開始が新しい方の id で詳細を開く', () {
    final older = _history(
      id: 'older',
      recordedAt: DateTime(2026, 11, 5, 10),
      creationStartedAt: DateTime(2026, 11, 5, 9),
    );
    final newer = _history(
      id: 'newer',
      recordedAt: DateTime(2026, 11, 5, 11),
      creationStartedAt: DateTime(2026, 11, 5, 12),
    );
    state = MutableStateStream(
      ExerciseHistoryScreenState(
        year: 2026,
        month: 11,
        items: [older, newer],
        loading: false,
        loadError: null,
        reloadGeneration: 1,
      ),
    );
    final nav = _Nav();
    OnTapDayDelegate(state: state, navigation: nav).execute(day: 5);
    expect(nav.openedId, 'newer');
  });

  test('state_to_entity は記録日にスタンプし月曜オフセットを付ける', () {
    const delegate = ExerciseHistoryStateToEntityDelegate();
    final empty = delegate.execute(
      ExerciseHistoryScreenState.initial(year: 2026, month: 11),
    );
    expect(empty.showLoading, isFalse);
    expect(empty.showError, isFalse);
    expect(empty.monthLabel, contains('2026'));
    expect(empty.monthLabel, contains('11'));
    expect(empty.weekdayLabels, ['月', '火', '水', '木', '金', '土', '日']);
    // 2026-11-01 は日曜 → 月曜始まりで先頭空白 6
    expect(empty.dayCells.take(6).every((c) => c.day == null), isTrue);
    expect(empty.dayCells[6].day, 1);
    expect(empty.dayCells.where((c) => c.day != null).length, 30);
    expect(empty.dayCells.length % 7, 0);

    final stamped = delegate.execute(
      ExerciseHistoryScreenState(
        year: 2026,
        month: 11,
        items: [
          _history(
            id: 'a',
            recordedAt: DateTime(2026, 11, 5, 8),
            creationStartedAt: DateTime(2026, 11, 4, 20),
          ),
          _history(id: 'b', recordedAt: DateTime(2026, 11, 5, 9)),
          _history(id: 'c', recordedAt: DateTime(2026, 11, 6)),
        ],
        loading: false,
        loadError: null,
        reloadGeneration: 1,
      ),
    );
    final day5 = stamped.dayCells.firstWhere((c) => c.day == 5);
    final day6 = stamped.dayCells.firstWhere((c) => c.day == 6);
    final day4 = stamped.dayCells.firstWhere((c) => c.day == 4);
    expect(day5.stampCount, 2);
    expect(day5.isTappable, isTrue);
    expect(day5.semanticsLabel, contains('2'));
    expect(day6.stampCount, 1);
    expect(day4.stampCount, 0);
    expect(day4.isTappable, isFalse);
  });

  test('stamp_semantics 文言が StringsTestHelper から取れる', () {
    final ja = jsonDecode(StringsTestHelper.ja) as Map<String, Object?>;
    expect(
      ja['screen_feature_exercise_history_stamp_semantics_one'],
      isNotNull,
    );
    expect(
      ja['screen_feature_exercise_history_stamp_semantics_other'],
      isNotNull,
    );
    expect(ja['screen_feature_exercise_history_count_badge'], isNotNull);
  });
}
