import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';

import '../state/achievement_screen_state.dart';

/// 一覧を初回読み込み、State を置き換える。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadUsecase: loadUsecase,
///   markViewed: markViewed,
///   now: DateTime(2026, 11, 10),
/// );
/// ```
final class OnInitializeDelegate {
  /// [state] と読込・閲覧更新 Usecase、基準時刻を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnInitializeDelegate(
  ///   state: state,
  ///   loadUsecase: loadUsecase,
  ///   markViewed: markViewed,
  ///   now: DateTime(2026, 11, 10),
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.loadUsecase,
    required this.markViewed,
    required this.now,
  });

  /// 画面状態。
  final MutableStateStream<AchievementScreenState> state;

  /// 一覧の読込。
  final LoadAchievementsUsecase loadUsecase;

  /// Ready 後の最終閲覧更新。
  final MarkAchievementsViewedUsecase markViewed;

  /// 進捗算出の基準時刻。
  final DateTime now;

  /// 読込中にしてから一覧を取得し、成功または失敗へ遷移する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    try {
      await state.updateWithLock((_, emitter) async {
        await emitter.emit(const AchievementScreenLoading());
      });
    } on StateStreamClosedException {
      return;
    }
    await loadAchievementsIntoState(
      state: state,
      loadUsecase: loadUsecase,
      markViewed: markViewed,
      now: now,
    );
  }
}

/// 一覧 Usecase を呼び、成功または失敗を [state] へ書く。
///
/// Example:
/// ```dart
/// loadAchievementsIntoState(
///   state: state,
///   loadUsecase: usecase,
///   markViewed: markViewed,
///   now: DateTime(2026, 11, 10),
/// );
/// ```
@internal
Future<void> loadAchievementsIntoState({
  required MutableStateStream<AchievementScreenState> state,
  required LoadAchievementsUsecase loadUsecase,
  required MarkAchievementsViewedUsecase markViewed,
  required DateTime now,
}) async {
  try {
    final result = await loadUsecase.execute(LoadAchievementsRequest(now: now));
    try {
      await state.updateWithLock((_, emitter) async {
        await emitter.emit(switch (result) {
          LoadAchievementsSuccess(:final rows) => AchievementScreenReady(rows),
          LoadAchievementsFailed() => const AchievementScreenFailed(),
        });
      });
    } on StateStreamClosedException {
      return;
    }
    if (result is LoadAchievementsSuccess) {
      try {
        await markViewed.execute(MarkAchievementsViewedRequest(now: now));
      } on Object {
        // 一覧は出したまま。閲覧日時だけ次回に持ち越す。
      }
    }
  } on Object {
    try {
      await state.updateWithLock((_, emitter) async {
        await emitter.emit(const AchievementScreenFailed());
      });
    } on StateStreamClosedException {
      return;
    }
  }
}
