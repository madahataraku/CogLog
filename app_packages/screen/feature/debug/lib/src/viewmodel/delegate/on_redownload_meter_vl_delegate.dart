import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

import '../state/debug_screen_state.dart';

/// 確認ダイアログ後に LFM VL 再ダウンロードセッションを開始する。
///
/// Example:
/// ```dart
/// OnRedownloadMeterVlDelegate(
///   session: session,
///   usecase: usecase,
///   state: state,
/// ).execute();
/// ```
@internal
final class OnRedownloadMeterVlDelegate {
  /// session / usecase / 画面 State を束ねる。
  ///
  /// Example:
  /// ```dart
  /// OnRedownloadMeterVlDelegate(
  ///   session: session,
  ///   usecase: usecase,
  ///   state: state,
  /// );
  /// ```
  const OnRedownloadMeterVlDelegate({
    required this.session,
    required this.usecase,
    required this.state,
  });

  /// 開始対象のプロセス内セッション（画面離脱後も生存）。
  final MeterVlRedownloadSession session;

  /// 削除→再準備を実行する Usecase。
  final RedownloadMeterVlModelUsecase usecase;

  /// 開始拒否理由（conflict / running）を書き戻す画面 State。
  final MutableStateStream<DebugScreenState> state;

  /// セッションを開始する。二重／busy なら disabledReason を残し false。
  ///
  /// busy 拒否は [DebugRedownloadDisabledReason.conflict]（理由表示のみ・ボタンは有効のまま）。
  /// 実行中拒否は [DebugRedownloadDisabledReason.redownloadRunning]（ボタン無効）。
  /// 開始できたときは disabledReason を clear する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<bool> execute() async {
    final started = await session.start(usecase: usecase);
    if (!started) {
      final reason = session.isRunning
          ? DebugRedownloadDisabledReason.redownloadRunning
          : DebugRedownloadDisabledReason.conflict;
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(current.copyWith(redownloadDisabledReason: reason));
      });
    } else {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          current.copyWith(clearRedownloadDisabledReason: true),
        );
      });
    }
    return started;
  }
}
