import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';

import '../state/trends_screen_state.dart';
import 'on_reload_delegate.dart';

/// 画面表示時に系列を読み込む。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadTrendsUsecase: loadTrendsUsecase,
///   now: DateTime(2026, 11, 10),
/// ).execute();
/// ```
final class OnInitializeDelegate {
  /// [state]・読込 Usecase・基準時刻を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnInitializeDelegate(
  ///   state: state,
  ///   loadTrendsUsecase: loadTrendsUsecase,
  ///   now: DateTime(2026, 11, 10),
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.loadTrendsUsecase,
    required this.now,
  });

  /// 更新する画面状態。
  final MutableStateStream<TrendsScreenState> state;

  /// 系列の読み込み。
  final LoadTrendsUsecase loadTrendsUsecase;

  /// バケット境界に使う時刻。
  final DateTime now;

  /// [OnReloadDelegate] へ委譲する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() => OnReloadDelegate(
    state: state,
    loadTrendsUsecase: loadTrendsUsecase,
    now: now,
  ).execute();
}
