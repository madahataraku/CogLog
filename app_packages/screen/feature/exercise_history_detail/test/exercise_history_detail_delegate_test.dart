import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history_detail/src/viewmodel/delegate/exercise_history_detail_state_to_entity_delegate.dart';
import 'package:screen_feature_exercise_history_detail/src/viewmodel/delegate/on_initialize_delegate.dart';
import 'package:screen_feature_exercise_history_detail/src/viewmodel/state/exercise_history_detail_screen_state.dart';
import 'package:state_stream/state_stream.dart';
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
  _LoadDetail(this.result);

  final LoadExerciseHistoryDetailResult result;
  var calls = 0;

  @override
  Future<LoadExerciseHistoryDetailResult> execute(
    LoadExerciseHistoryDetailRequest request,
  ) async {
    calls += 1;
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
    ).execute(id: 'missing');

    expect(state.state.missing, isTrue);
    expect(state.state.history, isNull);
    expect(state.state.loading, isFalse);
  });

  test('写真無し成功は path null', () async {
    final history = _history(id: 'a');
    await OnInitializeDelegate(
      state: state,
      loadDetailUsecase: _LoadDetail(
        LoadExerciseHistoryDetailSuccess(
          history: history,
          photoAbsolutePath: null,
        ),
      ),
    ).execute(id: 'a');

    expect(state.state.history, history);
    expect(state.state.photoAbsolutePath, isNull);
    expect(state.state.missing, isFalse);
  });

  test('編集済みはサフィックス、写真無しは showPhotoError', () {
    const delegate = ExerciseHistoryDetailStateToEntityDelegate();
    final entity = delegate.execute(
      ExerciseHistoryDetailScreenState(
        id: 'a',
        loading: false,
        history: _history(id: 'a', edited: true),
        photoAbsolutePath: null,
        missing: false,
        error: null,
      ),
    );
    expect(entity.recordedAtEditedSuffix, isNotEmpty);
    expect(entity.showPhoto, isFalse);
    expect(entity.showPhotoError, isTrue);
    expect(entity.caloriesText, contains('12.3'));
    expect(entity.averageSpeedText, contains('2.5'));
  });

  test('missing entity は showMissing', () {
    const delegate = ExerciseHistoryDetailStateToEntityDelegate();
    final entity = delegate.execute(
      const ExerciseHistoryDetailScreenState(
        id: 'x',
        loading: false,
        history: null,
        photoAbsolutePath: null,
        missing: true,
        error: null,
      ),
    );
    expect(entity.showMissing, isTrue);
  });
}
