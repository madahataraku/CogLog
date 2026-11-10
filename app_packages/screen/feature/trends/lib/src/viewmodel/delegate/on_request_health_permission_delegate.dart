import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';
import 'package:usecase_request_health_body_permission/usecase_request_health_body_permission.dart';

import '../state/trends_screen_state.dart';
import 'on_reload_delegate.dart';

/// ヘルス許可をリクエストし、系列を読み直す。
///
/// Example:
/// ```dart
/// OnRequestHealthPermissionDelegate(
///   state: state,
///   requestHealthPermissionUsecase: requestHealthPermissionUsecase,
///   loadTrendsUsecase: loadTrendsUsecase,
///   now: DateTime(2026, 11, 10),
/// ).execute();
/// ```
final class OnRequestHealthPermissionDelegate {
  /// 許可・読込 Usecase と State を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnRequestHealthPermissionDelegate(
  ///   state: state,
  ///   requestHealthPermissionUsecase: requestHealthPermissionUsecase,
  ///   loadTrendsUsecase: loadTrendsUsecase,
  ///   now: DateTime(2026, 11, 10),
  /// );
  /// ```
  const OnRequestHealthPermissionDelegate({
    required this.state,
    required this.requestHealthPermissionUsecase,
    required this.loadTrendsUsecase,
    required this.now,
  });

  /// 更新する画面状態。
  final MutableStateStream<TrendsScreenState> state;

  /// 身体指標の許可リクエスト。
  final RequestHealthBodyPermissionUsecase requestHealthPermissionUsecase;

  /// 系列の読み込み。
  final LoadTrendsUsecase loadTrendsUsecase;

  /// バケット境界に使う時刻。
  final DateTime now;

  /// 許可ダイアログのあと系列を取り直す。
  ///
  /// 要求自体が例外で失敗したときは再読込せず [TrendsScreenState.bodyReadFailed]
  /// を立て、再試行ボタンから復旧できるようにする。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    try {
      await requestHealthPermissionUsecase.execute();
    } catch (_) {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          current.copyWith(
            bodyReadFailed: true,
            healthPermissionRequested: true,
          ),
        );
      });
      return;
    }
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(healthPermissionRequested: true));
    });
    await OnReloadDelegate(
      state: state,
      loadTrendsUsecase: loadTrendsUsecase,
      now: now,
    ).execute();
  }
}
