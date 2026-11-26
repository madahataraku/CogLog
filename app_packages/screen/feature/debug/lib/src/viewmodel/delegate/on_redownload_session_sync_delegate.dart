import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

import '../state/debug_screen_state.dart';

/// session スナップショットを [DebugScreenState] へ写す。
///
/// phase==running のあいだは [redownloadDisabledReason] を
/// [DebugRedownloadDisabledReason.redownloadRunning] に寄せる。
/// phase が running 以外になったとき、現在の理由が [DebugRedownloadDisabledReason.redownloadRunning]
/// なら `clearRedownloadDisabledReason: true` で消す。
/// （`copyWith(redownloadDisabledReason: null)` だけでは消えない。
/// `?? this.redownloadDisabledReason` のため clear フラグが必須。）
/// [DebugRedownloadDisabledReason.conflict] は [OnRedownloadMeterVlDelegate] が start false のときだけセットする。
///
/// Example:
/// ```dart
/// OnRedownloadSessionSyncDelegate(state: state).execute(sessionState);
/// ```
@internal
final class OnRedownloadSessionSyncDelegate {
  /// 同期先の画面 State を束ねる。
  ///
  /// Example:
  /// ```dart
  /// OnRedownloadSessionSyncDelegate(state: state);
  /// ```
  const OnRedownloadSessionSyncDelegate({required this.state});

  /// session スナップショットの書き込み先。
  final MutableStateStream<DebugScreenState> state;

  /// session スナップショットを State へ同期する。
  ///
  /// Example:
  /// ```dart
  /// await OnRedownloadSessionSyncDelegate(state: state)
  ///     .execute(sessionState);
  /// ```
  Future<void> execute(MeterVlRedownloadSessionState sessionState) async {
    await state.updateWithLock((current, emitter) async {
      final clearRunningReason =
          sessionState.phase != MeterVlRedownloadPhase.running &&
          current.redownloadDisabledReason ==
              DebugRedownloadDisabledReason.redownloadRunning;
      final disabled = sessionState.phase == MeterVlRedownloadPhase.running
          ? DebugRedownloadDisabledReason.redownloadRunning
          : current.redownloadDisabledReason;
      await emitter.emit(
        current.copyWith(
          redownloadPhase: sessionState.phase,
          redownloadProgress: sessionState.progress,
          redownloadFailureKind: sessionState.failureKind,
          clearRedownloadFailureKind: sessionState.failureKind == null,
          diagnoseRefreshPending: sessionState.diagnoseRefreshPending,
          redownloadDisabledReason: clearRunningReason ? null : disabled,
          clearRedownloadDisabledReason: clearRunningReason,
        ),
      );
    });
  }
}
