import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';

import '../state/exercise_history_screen_state.dart';

/// スタンプ日の先頭履歴詳細へ遷移する。
///
/// Example:
/// ```dart
/// OnTapDayDelegate(state: state, navigation: navigation).execute(day: 5);
/// ```
final class OnTapDayDelegate {
  /// [state] と [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnTapDayDelegate(state: state, navigation: navigation);
  /// ```
  const OnTapDayDelegate({required this.state, required this.navigation});

  /// 履歴一覧の画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// 記録日時がその日の履歴を作成開始日時降順で並べ、先頭の詳細を開く。
  ///
  /// 同時刻は ID 降順。該当が無ければ何もしない。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(day: 5);
  /// ```
  void execute({required int day}) {
    final current = state.state;
    final onDay =
        current.items.where((h) {
          final l = h.recordedAt.toLocal();
          return l.year == current.year &&
              l.month == current.month &&
              l.day == day;
        }).toList()..sort((a, b) {
          final c = b.creationStartedAt.compareTo(a.creationStartedAt);
          return c != 0 ? c : b.id.compareTo(a.id);
        });
    if (onDay.isEmpty) {
      return;
    }
    navigation.openExerciseHistoryDetail(id: onDay.first.id);
  }
}
