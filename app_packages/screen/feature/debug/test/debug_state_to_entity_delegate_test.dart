import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:screen_feature_debug/src/viewmodel/delegate/debug_state_to_entity_delegate.dart';
import 'package:screen_feature_debug/src/viewmodel/state/debug_screen_state.dart';
import 'package:test/test.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';

void main() {
  test('結果無しはハイフンと空ログ', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState.initial,
    );
    expect(entity.readiness, '-');
    expect(entity.canGenerate, isNull);
    expect(entity.logLines, isEmpty);
    expect(entity.forceSpatialOcr, isFalse);
  });

  test('結果とログと強制フラグを写す', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState(
        running: false,
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
        logs: [
          AppLogEntry(
            at: DateTime.utc(2026, 1, 1, 12, 30, 5),
            level: AppLogLevel.info,
            tag: 't',
            message: 'm',
          ),
        ],
        forceSpatialOcr: true,
      ),
    );
    expect(entity.readiness, 'ready');
    expect(entity.canGenerate, isTrue);
    expect(entity.sampleOutput, 'hi');
    expect(entity.logLines.single, contains('t: m'));
    expect(entity.forceSpatialOcr, isTrue);
  });

  test('古い行が先（3件）', () {
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState(
        running: false,
        result: null,
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
        forceSpatialOcr: false,
      ),
    );
    expect(entity.logLines, hasLength(3));
    expect(entity.logLines.first, contains('first'));
    expect(entity.logLines.last, contains('third'));
  });

  test('長文が省略されない', () {
    final longMessage = 'x' * 5000;
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState(
        running: false,
        result: null,
        logs: [
          AppLogEntry(
            at: DateTime.utc(2026, 1, 1, 12, 0, 0),
            level: AppLogLevel.info,
            tag: 't',
            message: longMessage,
          ),
        ],
        forceSpatialOcr: false,
      ),
    );
    expect(entity.logLines.single, contains(longMessage));
  });

  test('改行を正規化しない', () {
    const multilineMessage = 'line1\nline2';
    final entity = const DebugStateToEntityDelegate().execute(
      DebugScreenState(
        running: false,
        result: null,
        logs: [
          AppLogEntry(
            at: DateTime.utc(2026, 1, 1, 12, 0, 0),
            level: AppLogLevel.info,
            tag: 't',
            message: multilineMessage,
          ),
        ],
        forceSpatialOcr: false,
      ),
    );
    expect(entity.logLines.single, contains(multilineMessage));
  });
}
