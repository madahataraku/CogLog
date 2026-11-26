import 'package:infra_meter_vl_testing/infra_meter_vl_testing.dart';
import 'package:screen_feature_debug/src/viewmodel/delegate/on_redownload_meter_vl_delegate.dart';
import 'package:screen_feature_debug/src/viewmodel/state/debug_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:test/test.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

import 'fake_redownload_meter_vl_model_usecase.dart';

void main() {
  test('start true なら disabledReason をクリアする', () async {
    final session = MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
    final usecase = FakeRedownloadMeterVlModelUsecase();
    final state = MutableStateStream(
      DebugScreenState.initial.copyWith(
        redownloadDisabledReason: DebugRedownloadDisabledReason.conflict,
      ),
    );

    final started = await OnRedownloadMeterVlDelegate(
      session: session,
      usecase: usecase,
      state: state,
    ).execute();

    expect(started, isTrue);
    expect(state.state.redownloadDisabledReason, isNull);
    await session.close();
  });

  test('start false（busy）なら conflict を残す', () async {
    final session = MeterVlRedownloadSession(
      meterVl: FakeMeterVlVision(operationBusy: true),
    );
    final usecase = FakeRedownloadMeterVlModelUsecase();
    final state = MutableStateStream(DebugScreenState.initial);

    final started = await OnRedownloadMeterVlDelegate(
      session: session,
      usecase: usecase,
      state: state,
    ).execute();

    expect(started, isFalse);
    expect(
      state.state.redownloadDisabledReason,
      DebugRedownloadDisabledReason.conflict,
    );
    expect(usecase.executeCallCount, 0);
    await session.close();
  });

  test('start false（running）なら redownloadRunning を残す', () async {
    final session = MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
    await session.state.updateWithLock((current, emitter) async {
      await emitter.emit(
        const MeterVlRedownloadSessionState(
          phase: MeterVlRedownloadPhase.running,
          progress: 0,
          failureKind: null,
          diagnoseRefreshPending: false,
        ),
      );
    });
    final state = MutableStateStream(DebugScreenState.initial);

    final started = await OnRedownloadMeterVlDelegate(
      session: session,
      usecase: FakeRedownloadMeterVlModelUsecase(),
      state: state,
    ).execute();

    expect(started, isFalse);
    expect(
      state.state.redownloadDisabledReason,
      DebugRedownloadDisabledReason.redownloadRunning,
    );
    await session.close();
  });
}
