import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';

import '../state/top_screen_state.dart';

/// アチーブメント画面を開き、戻り後に新規有無を更新する。
///
/// Example:
/// ```dart
/// OnOpenAchievementsDelegate(
///   navigation: navigation,
///   state: state,
///   newIndicator: newIndicator,
///   now: DateTime.now,
/// ).execute();
/// ```
final class OnOpenAchievementsDelegate {
  /// 遷移と新規再読込に使う依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnOpenAchievementsDelegate(
  ///   navigation: navigation,
  ///   state: state,
  ///   newIndicator: newIndicator,
  ///   now: DateTime.now,
  /// );
  /// ```
  const OnOpenAchievementsDelegate({
    required this.navigation,
    required this.state,
    required this.newIndicator,
    required this.now,
  });

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// ホームの画面状態。
  final MutableStateStream<TopScreenState> state;

  /// 新規アチーブメント有無。
  final LoadAchievementNewIndicatorUsecase newIndicator;

  /// 新規判定の基準時刻。
  final DateTime Function() now;

  /// アチーブメントへ遷移し、戻ったあと新規ドットを更新する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await navigation.openAchievements();
    final hasNew = await newIndicator.execute(now: now());
    try {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(current.copyWith(hasNewAchievements: hasNew));
      });
    } on StateStreamClosedException {
      return;
    }
  }
}
