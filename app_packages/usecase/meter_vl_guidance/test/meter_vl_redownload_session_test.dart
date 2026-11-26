import 'dart:async';

import 'package:infra_meter_vl_testing/infra_meter_vl_testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

/// テスト用の再ダウンロード Usecase。
final class FakeRedownloadMeterVlModelUsecase
    implements RedownloadMeterVlModelUsecase {
  FakeRedownloadMeterVlModelUsecase({
    this.progressValues = const [1.0],
    this.throwOnExecute,
    this.throwErrorOnExecute = false,
    this.gate,
  });

  final List<double> progressValues;
  final Exception? throwOnExecute;
  final bool throwErrorOnExecute;
  final Completer<void>? gate;

  int executeCallCount = 0;

  @override
  Stream<double> execute() async* {
    executeCallCount++;
    if (throwOnExecute != null) {
      throw throwOnExecute!;
    }
    if (throwErrorOnExecute) {
      Error.throwWithStackTrace(ArgumentError('test'), StackTrace.current);
    }
    if (gate != null) {
      await gate!.future;
    }
    for (final progress in progressValues) {
      yield progress;
    }
  }
}

void main() {
  group('MeterVlRedownloadSession', () {
    test('正常完了', () async {
      final session = MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
      final usecase = FakeRedownloadMeterVlModelUsecase(
        progressValues: [0.4, 1.0],
      );

      final started = await session.start(usecase: usecase);

      expect(started, isTrue);
      expect(session.state.state.phase, MeterVlRedownloadPhase.success);
      expect(session.state.state.progress, 1);
      expect(session.state.state.diagnoseRefreshPending, isTrue);
      await session.close();
    });

    test('実行中の二重 start', () async {
      final gate = Completer<void>();
      final session = MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
      final usecase = FakeRedownloadMeterVlModelUsecase(gate: gate);
      final emissions = <MeterVlRedownloadSessionState>[];
      final sub = session.state.stream.listen(emissions.add);

      final first = session.start(usecase: usecase);
      await Future<void>.delayed(Duration.zero);
      final second = await session.start(
        usecase: FakeRedownloadMeterVlModelUsecase(),
      );
      gate.complete();
      final firstResult = await first;

      expect(firstResult, isTrue);
      expect(second, isFalse);
      expect(session.state.state.phase, MeterVlRedownloadPhase.success);
      expect(
        emissions
            .where((s) => s.phase == MeterVlRedownloadPhase.running)
            .length,
        greaterThanOrEqualTo(1),
      );
      await sub.cancel();
      await session.close();
    });

    test('並行 start（同時）', () async {
      final session = MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
      final usecase = FakeRedownloadMeterVlModelUsecase(
        progressValues: [0.5, 1.0],
      );

      final results = await Future.wait([
        session.start(usecase: usecase),
        session.start(usecase: usecase),
      ]);

      expect(results.where((r) => r).length, 1);
      expect(results.where((r) => !r).length, 1);
      expect(session.state.state.phase, MeterVlRedownloadPhase.success);
      await session.close();
    });

    test('busy', () async {
      final session = MeterVlRedownloadSession(
        meterVl: FakeMeterVlVision(operationBusy: true),
      );
      final usecase = FakeRedownloadMeterVlModelUsecase();

      final started = await session.start(usecase: usecase);

      expect(started, isFalse);
      expect(session.state.state.phase, MeterVlRedownloadPhase.idle);
      expect(usecase.executeCallCount, 0);
      await session.close();
    });

    test('prepare 失敗（Exception）', () async {
      final session = MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
      final usecase = FakeRedownloadMeterVlModelUsecase(
        throwOnExecute: const MeterVlPrepareException(
          MeterVlPrepareFailureKind.insufficientStorage,
        ),
      );

      final started = await session.start(usecase: usecase);

      expect(started, isTrue);
      expect(session.state.state.phase, MeterVlRedownloadPhase.failure);
      expect(
        session.state.state.failureKind,
        MeterVlPrepareFailureKind.insufficientStorage,
      );
      expect(session.state.state.diagnoseRefreshPending, isTrue);
      await session.close();
    });

    test('想定外 Error', () async {
      final session = MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
      final usecase = FakeRedownloadMeterVlModelUsecase(
        throwErrorOnExecute: true,
      );

      await expectLater(
        session.start(usecase: usecase),
        throwsA(isA<ArgumentError>()),
      );
      expect(session.state.state.phase, MeterVlRedownloadPhase.failure);
      expect(
        session.state.state.failureKind,
        MeterVlPrepareFailureKind.generic,
      );
      expect(session.state.state.diagnoseRefreshPending, isTrue);

      final restarted = await session.start(
        usecase: FakeRedownloadMeterVlModelUsecase(),
      );
      // diagnoseRefreshPending 中は新規 start を拒む。
      expect(restarted, isFalse);

      await session.acknowledgeDiagnoseRefresh();
      final afterAck = await session.start(
        usecase: FakeRedownloadMeterVlModelUsecase(),
      );
      expect(afterAck, isTrue);
      expect(session.state.state.phase, MeterVlRedownloadPhase.success);
      await session.close();
    });

    test('diagnoseRefreshPending 中は start を拒む', () async {
      final session = MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
      await session.start(usecase: FakeRedownloadMeterVlModelUsecase());
      expect(session.state.state.diagnoseRefreshPending, isTrue);

      final second = await session.start(
        usecase: FakeRedownloadMeterVlModelUsecase(),
      );

      expect(second, isFalse);
      expect(session.state.state.phase, MeterVlRedownloadPhase.success);
      expect(session.state.state.diagnoseRefreshPending, isTrue);
      await session.close();
    });

    test('acknowledge', () async {
      final session = MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
      await session.start(usecase: FakeRedownloadMeterVlModelUsecase());
      expect(session.state.state.diagnoseRefreshPending, isTrue);

      await session.acknowledgeDiagnoseRefresh();

      expect(session.state.state.diagnoseRefreshPending, isFalse);
      await session.close();
    });
  });
}
