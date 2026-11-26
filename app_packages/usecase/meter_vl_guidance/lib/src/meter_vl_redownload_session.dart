import 'dart:async';

import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:riverpod/riverpod.dart';
import 'package:state_stream/state_stream.dart';

import 'meter_vl_redownload_session_state.dart';
import 'redownload_meter_vl_model_usecase.dart';

/// デバッグ LFM VL 再ダウンロードのプロセス内セッション。
///
/// Example:
/// ```dart
/// MeterVlRedownloadSession.provider;
/// ```
final class MeterVlRedownloadSession {
  /// プロセススコープの注入点。内部で [Ref.keepAlive] する。
  ///
  /// Example:
  /// ```dart
  /// MeterVlRedownloadSession.provider;
  /// ```
  static final provider = Provider<MeterVlRedownloadSession>((ref) {
    ref.keepAlive();
    final session = MeterVlRedownloadSession(
      meterVl: ref.watch(meterVlVisionProvider),
    );
    ref.onDispose(() {
      unawaited(session.close());
    });
    return session;
  });

  /// [meterVl] で busy 判定し、状態ストリームを持つセッションを作る。
  ///
  /// Example:
  /// ```dart
  /// MeterVlRedownloadSession(meterVl: fakeMeterVl);
  /// ```
  MeterVlRedownloadSession({
    required MeterVlVision meterVl,
    MutableStateStream<MeterVlRedownloadSessionState>? state,
  }) : _meterVl = meterVl,
       state =
           state ?? MutableStateStream(MeterVlRedownloadSessionState.initial);

  /// start 前の live busy 判定に使う [MeterVlVision]。
  ///
  /// 画面／Delegate には渡さない。Session 内のみ参照する。
  final MeterVlVision _meterVl;

  /// 相・進捗・失敗・診断更新待ちを保持するプロセス内ストリーム。
  ///
  /// 現在値は [MutableStateStream.state]、購読は [MutableStateStream.stream]。
  final MutableStateStream<MeterVlRedownloadSessionState> state;

  /// 現在の相が running なら true（二重開始判定用）。
  bool get isRunning => state.state.phase == MeterVlRedownloadPhase.running;

  /// 二重開始・busy なら false。開始コミットしたら true（結果が failure でも true）。
  ///
  /// 手順（この順序を崩さない）:
  /// 1. `await _meterVl.isOperationBusy` が true なら false（phase は変えない）
  /// 2. `updateWithLock` 内で `phase==running` なら **emit せず** false
  /// 3. さもなくば running を emit してコミット
  /// 4. コミット後に `usecase.execute()` を走らせ進捗を写す
  ///
  /// Example:
  /// ```dart
  /// await session.start(usecase: usecase);
  /// ```
  Future<bool> start({required RedownloadMeterVlModelUsecase usecase}) async {
    if (await _meterVl.isOperationBusy) {
      return false;
    }
    var committed = false;
    await state.updateWithLock((current, emitter) async {
      if (current.phase == MeterVlRedownloadPhase.running) {
        // 並行 start: emit しない。
        return;
      }
      await emitter.emit(
        const MeterVlRedownloadSessionState(
          phase: MeterVlRedownloadPhase.running,
          progress: 0,
          failureKind: null,
          diagnoseRefreshPending: false,
        ),
      );
      committed = true;
    });
    if (!committed) {
      return false;
    }
    try {
      await for (final progress in usecase.execute()) {
        await state.updateWithLock((current, emitter) async {
          await emitter.emit(
            MeterVlRedownloadSessionState(
              phase: MeterVlRedownloadPhase.running,
              progress: progress.clamp(0.0, 1.0),
              failureKind: null,
              diagnoseRefreshPending: false,
            ),
          );
        });
      }
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          const MeterVlRedownloadSessionState(
            phase: MeterVlRedownloadPhase.success,
            progress: 1,
            failureKind: null,
            diagnoseRefreshPending: true,
          ),
        );
      });
      return true;
    } on Exception catch (error) {
      // Exception のみ session failure に畳む。Error は想定外として再 throw。
      final kind = error is MeterVlPrepareException
          ? error.kind
          : MeterVlPrepareFailureKind.generic;
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          MeterVlRedownloadSessionState(
            phase: MeterVlRedownloadPhase.failure,
            progress: current.progress,
            failureKind: kind,
            diagnoseRefreshPending: true,
          ),
        );
      });
      return true; // 開始はした（結果は failure）
    }
  }

  /// デバッグ画面が再診断を完了したあと、[diagnoseRefreshPending] を落とす。
  ///
  /// pending が false なら何もしない。
  ///
  /// Example:
  /// ```dart
  /// await session.acknowledgeDiagnoseRefresh();
  /// ```
  Future<void> acknowledgeDiagnoseRefresh() async {
    await state.updateWithLock((current, emitter) async {
      if (!current.diagnoseRefreshPending) {
        return;
      }
      await emitter.emit(
        MeterVlRedownloadSessionState(
          phase: current.phase,
          progress: current.progress,
          failureKind: current.failureKind,
          diagnoseRefreshPending: false,
        ),
      );
    });
  }

  /// プロセススコープ解放時に状態ストリームを閉じ、以降の購読を止める。
  ///
  /// Example:
  /// ```dart
  /// await session.close();
  /// ```
  Future<void> close() => state.close();
}
