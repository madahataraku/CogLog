import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:screen_feature_debug/src/viewmodel/delegate/on_redownload_session_sync_delegate.dart';
import 'package:screen_feature_debug/src/viewmodel/state/debug_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:test/test.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

void main() {
  test('phase running なら redownloadRunning と進捗を同期する', () async {
    final state = MutableStateStream(DebugScreenState.initial);

    await OnRedownloadSessionSyncDelegate(state: state).execute(
      const MeterVlRedownloadSessionState(
        phase: MeterVlRedownloadPhase.running,
        progress: 0.4,
        failureKind: null,
        diagnoseRefreshPending: false,
      ),
    );

    expect(state.state.redownloadPhase, MeterVlRedownloadPhase.running);
    expect(state.state.redownloadProgress, 0.4);
    expect(
      state.state.redownloadDisabledReason,
      DebugRedownloadDisabledReason.redownloadRunning,
    );
  });

  test('phase success のあと redownloadRunning 理由をクリアする', () async {
    final state = MutableStateStream(
      DebugScreenState.initial.copyWith(
        redownloadDisabledReason: DebugRedownloadDisabledReason.redownloadRunning,
        redownloadPhase: MeterVlRedownloadPhase.running,
      ),
    );

    await OnRedownloadSessionSyncDelegate(state: state).execute(
      const MeterVlRedownloadSessionState(
        phase: MeterVlRedownloadPhase.success,
        progress: 1,
        failureKind: null,
        diagnoseRefreshPending: true,
      ),
    );

    expect(state.state.redownloadPhase, MeterVlRedownloadPhase.success);
    expect(state.state.redownloadDisabledReason, isNull);
  });

  test('phase failure のあと redownloadRunning 理由をクリアする', () async {
    final state = MutableStateStream(
      DebugScreenState.initial.copyWith(
        redownloadDisabledReason: DebugRedownloadDisabledReason.redownloadRunning,
        redownloadPhase: MeterVlRedownloadPhase.running,
      ),
    );

    await OnRedownloadSessionSyncDelegate(state: state).execute(
      const MeterVlRedownloadSessionState(
        phase: MeterVlRedownloadPhase.failure,
        progress: 0.2,
        failureKind: MeterVlPrepareFailureKind.insufficientStorage,
        diagnoseRefreshPending: true,
      ),
    );

    expect(state.state.redownloadPhase, MeterVlRedownloadPhase.failure);
    expect(state.state.redownloadFailureKind,
        MeterVlPrepareFailureKind.insufficientStorage);
    expect(state.state.redownloadDisabledReason, isNull);
  });

  test('conflict は idle でも保持する', () async {
    final state = MutableStateStream(
      DebugScreenState.initial.copyWith(
        redownloadDisabledReason: DebugRedownloadDisabledReason.conflict,
      ),
    );

    await OnRedownloadSessionSyncDelegate(state: state).execute(
      const MeterVlRedownloadSessionState(
        phase: MeterVlRedownloadPhase.idle,
        progress: 0,
        failureKind: null,
        diagnoseRefreshPending: false,
      ),
    );

    expect(
      state.state.redownloadDisabledReason,
      DebugRedownloadDisabledReason.conflict,
    );
  });
}