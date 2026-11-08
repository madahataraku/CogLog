import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';

import '../state/exercise_history_screen_state.dart';

/// 現地当月の先頭頁を読み、State を置き換える。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadPageUsecase: loadPageUsecase,
///   now: DateTime(2026, 11, 8),
/// ).execute();
/// ```
final class OnInitializeDelegate {
  /// [state] と一覧 Usecase、基準時刻を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnInitializeDelegate(
  ///   state: state,
  ///   loadPageUsecase: loadPageUsecase,
  ///   now: DateTime(2026, 11, 8),
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.loadPageUsecase,
    required this.now,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 一覧頁の読み込み。
  final LoadExerciseHistoryPageUsecase loadPageUsecase;

  /// 当月判定に使う時刻。
  final DateTime now;

  /// 当月をセットして先頭頁を読む。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    final local = now.toLocal();
    final year = local.year;
    final month = local.month;
    final shouldLoad = await state.updateWithLock((current, emitter) async {
      if (current.loading || current.refreshing) {
        return false;
      }
      await emitter.emit(
        ExerciseHistoryScreenState.initial(
          year: year,
          month: month,
        ).copyWith(loading: true),
      );
      return true;
    });
    if (!shouldLoad) {
      return;
    }
    await _loadFirstPage(
      state: state,
      loadPageUsecase: loadPageUsecase,
      year: year,
      month: month,
    );
  }
}

/// 指定月の先頭頁を読み、成功または失敗を State へ書く。
///
/// Example:
/// ```dart
/// _loadFirstPage(
///   state: state,
///   loadPageUsecase: usecase,
///   year: 2026,
///   month: 11,
/// );
/// ```
Future<void> _loadFirstPage({
  required MutableStateStream<ExerciseHistoryScreenState> state,
  required LoadExerciseHistoryPageUsecase loadPageUsecase,
  required int year,
  required int month,
}) async {
  try {
    final result = await loadPageUsecase.execute(
      LoadExerciseHistoryPageRequest(year: year, month: month, offset: 0),
    );
    try {
      await state.updateWithLock((current, emitter) async {
        if (current.year != year || current.month != month) {
          return;
        }
        await emitter.emit(
          current.copyWith(
            items: result.items,
            hasMore: result.hasMore,
            loading: false,
            refreshing: false,
            loadingMore: false,
            clearLoadError: true,
            clearLoadMoreError: true,
          ),
        );
      });
    } on StateStreamClosedException {
      return;
    }
  } catch (error) {
    try {
      await state.updateWithLock((current, emitter) async {
        if (current.year != year || current.month != month) {
          return;
        }
        await emitter.emit(
          current.copyWith(
            loading: false,
            refreshing: false,
            loadingMore: false,
            loadError: error,
            clearLoadMoreError: true,
          ),
        );
      });
    } on StateStreamClosedException {
      return;
    }
  }
}

/// 一覧の先頭頁読込を他 Delegate から再利用する口。
///
/// Example:
/// ```dart
/// loadExerciseHistoryFirstPage(
///   state: state,
///   loadPageUsecase: usecase,
///   year: 2026,
///   month: 11,
/// );
/// ```
Future<void> loadExerciseHistoryFirstPage({
  required MutableStateStream<ExerciseHistoryScreenState> state,
  required LoadExerciseHistoryPageUsecase loadPageUsecase,
  required int year,
  required int month,
}) => _loadFirstPage(
  state: state,
  loadPageUsecase: loadPageUsecase,
  year: year,
  month: month,
);
