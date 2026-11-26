import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_debug/src/viewmodel/delegate/debug_state_to_entity_delegate.dart';
import 'package:screen_feature_debug/src/viewmodel/delegate/on_redownload_session_sync_delegate.dart';
import 'package:screen_feature_debug/src/viewmodel/state/debug_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_diagnose_meter_vl/usecase_diagnose_meter_vl.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(LocalizeStringDelegate.resetDelegateForTest);
  test('結果無しはハイフンと空ログ', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial,
    );
    expect(entity.readiness, '-');
    expect(entity.canGenerate, isNull);
    expect(entity.meterVlReadiness, '-');
    expect(entity.meterVlCanGenerate, isNull);
    expect(entity.preferLfmVlOverOsLlm, isFalse);
    expect(entity.logLines, isEmpty);
  });

  test('結果とログを写す', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial.copyWith(
        result: const DiagnoseOnDeviceLlmResult(
          snapshot: OnDeviceLlmAvailabilitySnapshot(
            readiness: OnDeviceLlmReadiness.ready,
            status: 'available',
            reason: 'ready',
            message: 'ok',
          ),
          canGenerate: true,
          sampleOutput: 'hi',
        ),
        meterVlResult: const DiagnoseMeterVlResult(
          snapshot: MeterVlAvailabilitySnapshot(
            readiness: MeterVlReadiness.ready,
            status: 'available',
            reason: 'ready',
            message: 'meterVl ok',
            backend: 'gpu',
            visionBackend: 'cpu',
          ),
          canGenerate: true,
          probeOutputLength: 2,
        ),
        logs: [
          AppLogEntry(
            at: DateTime.utc(2026, 1, 1, 12, 30, 5),
            level: AppLogLevel.info,
            tag: 't',
            message: 'm',
          ),
        ],
        preferLfmVlOverOsLlm: true,
      ),
    );
    expect(entity.readiness, 'ready');
    expect(entity.canGenerate, isTrue);
    expect(entity.sampleOutput, 'hi');
    expect(entity.meterVlReadiness, 'ready');
    expect(entity.meterVlBackend, 'gpu');
    expect(entity.meterVlVisionBackend, 'cpu');
    expect(entity.meterVlCanGenerate, isTrue);
    expect(entity.meterVlProbeOutputLength, '2');
    expect(entity.preferLfmVlOverOsLlm, isTrue);
    expect(entity.logLines.single, contains('t: m'));
  });

  test('古い行が先（3件）', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial.copyWith(
        logs: [
          AppLogEntry(
            at: DateTime.utc(2026, 1, 1, 12, 0, 1),
            level: AppLogLevel.info,
            tag: 'a',
            message: 'first',
          ),
          AppLogEntry(
            at: DateTime.utc(2026, 1, 1, 12, 0, 2),
            level: AppLogLevel.info,
            tag: 'b',
            message: 'second',
          ),
          AppLogEntry(
            at: DateTime.utc(2026, 1, 1, 12, 0, 3),
            level: AppLogLevel.info,
            tag: 'c',
            message: 'third',
          ),
        ],
      ),
    );
    expect(entity.logLines, hasLength(3));
    expect(entity.logLines.first, contains('first'));
    expect(entity.logLines.last, contains('third'));
  });

  test('長文が省略されない', () {
    final longMessage = 'x' * 5000;
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial.copyWith(
        logs: [
          AppLogEntry(
            at: DateTime.utc(2026, 1, 1, 12, 0, 0),
            level: AppLogLevel.info,
            tag: 't',
            message: longMessage,
          ),
        ],
      ),
    );
    expect(entity.logLines.single, contains(longMessage));
  });

  test('改行を正規化しない', () {
    const multilineMessage = 'line1\nline2';
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial.copyWith(
        logs: [
          AppLogEntry(
            at: DateTime.utc(2026, 1, 1, 12, 0, 0),
            level: AppLogLevel.info,
            tag: 't',
            message: multilineMessage,
          ),
        ],
      ),
    );
    expect(entity.logLines.single, contains(multilineMessage));
  });

  test('再ダウンロード欄を idle から写す', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial,
    );
    expect(entity.redownloadEnabled, isTrue);
    expect(entity.redownloadDisabledReason, isEmpty);
    expect(entity.redownloadPhase, MeterVlRedownloadPhase.idle);
    expect(entity.redownloadProgress, 0);
    expect(entity.redownloadFailureKind, isNull);
    expect(entity.diagnoseRefreshPending, isFalse);
    expect(entity.redownloadStatusText, isEmpty);
  });

  test('unavailable で再ダウンロード無効', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial.copyWith(
        meterVlResult: const DiagnoseMeterVlResult(
          snapshot: MeterVlAvailabilitySnapshot(
            readiness: MeterVlReadiness.unavailable,
            status: 'unavailable',
            reason: 'unsupported',
            message: 'n/a',
            backend: '-',
            visionBackend: '-',
          ),
          canGenerate: false,
        ),
      ),
    );
    expect(entity.redownloadEnabled, isFalse);
    expect(
      entity.redownloadDisabledReason,
      'この端末では LFM VL を利用できません。',
    );
  });

  test('診断実行中で再ダウンロード無効', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial.copyWith(running: true),
    );
    expect(entity.redownloadEnabled, isFalse);
    expect(
      entity.redownloadDisabledReason,
      'メーター読み取りまたはモデル準備の完了を待ってから再度お試しください。',
    );
  });

  test('再ダウンロード実行中で無効', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial.copyWith(
        redownloadPhase: MeterVlRedownloadPhase.running,
        redownloadProgress: 0.4,
      ),
    );
    expect(entity.redownloadEnabled, isFalse);
    expect(entity.redownloadDisabledReason, '再ダウンロードの実行中です。');
    expect(entity.redownloadStatusText, 'LFM VL を再ダウンロード中…');
    expect(entity.redownloadProgress, 0.4);
  });

  test('conflict は文言を出しつつボタンは有効', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial.copyWith(
        redownloadDisabledReason: DebugRedownloadDisabledReason.conflict,
      ),
    );
    expect(entity.redownloadEnabled, isTrue);
    expect(
      entity.redownloadDisabledReason,
      'メーター読み取りまたはモデル準備の完了を待ってから再度お試しください。',
    );
  });

  test('statusText は phase から写す', () {
    final success = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial.copyWith(
        redownloadPhase: MeterVlRedownloadPhase.success,
      ),
    );
    expect(
      success.redownloadStatusText,
      'LFM VL の再ダウンロードが完了しました。',
    );

    final failure = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial.copyWith(
        redownloadPhase: MeterVlRedownloadPhase.failure,
        redownloadFailureKind: MeterVlPrepareFailureKind.insufficientStorage,
      ),
    );
    expect(
      failure.redownloadStatusText,
      '空き容量が足りません。容量を確保してから再度お試しください。',
    );
  });

  test('success 後 redownloadRunning 理由は残らない', () async {
    final state = MutableStateStream(
      DebugScreenState.initial.copyWith(
        redownloadDisabledReason:
            DebugRedownloadDisabledReason.redownloadRunning,
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
    final entity = const DebugStateToEntityDelegate().execute(state.state);
    expect(entity.redownloadEnabled, isTrue);
    expect(entity.redownloadDisabledReason, isEmpty);
  });
}
