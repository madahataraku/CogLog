import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';

/// [OnDeviceLlm] の詳細と短い生成を診断する実装。
///
/// Example:
/// ```dart
/// DiagnoseOnDeviceLlmUsecaseImpl(llm: llm, log: AppLogStore());
/// ```
final class DiagnoseOnDeviceLlmUsecaseImpl
    implements DiagnoseOnDeviceLlmUsecase {
  /// [llm] と任意の [log] / [generateTimeout] / [probePrompt] を持つ。
  ///
  /// Example:
  /// ```dart
  /// DiagnoseOnDeviceLlmUsecaseImpl(llm: llm);
  /// ```
  DiagnoseOnDeviceLlmUsecaseImpl({
    required this.llm,
    AppLogStore? log,
    this.generateTimeout = const Duration(seconds: 15),
    this.probePrompt =
        'Reply with exactly one short word in English. No other text.',
  }) : log = log ?? AppLogStore();

  /// 端末上 LLM。
  final OnDeviceLlm llm;

  /// 診断経過を残すログ。
  final AppLogStore log;

  /// 生成プローブの上限。
  final Duration generateTimeout;

  /// 生成プローブ用の短いプロンプト。
  final String probePrompt;

  /// スナップショットを取り、必要なら生成を試す。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<DiagnoseOnDeviceLlmResult> execute({bool probeGenerate = true}) async {
    late final OnDeviceLlmAvailabilitySnapshot snapshot;
    try {
      snapshot = await llm.availabilitySnapshot;
    } on Object catch (error) {
      snapshot = OnDeviceLlmAvailabilitySnapshot(
        readiness: OnDeviceLlmReadiness.unavailable,
        status: 'error',
        reason: 'exception',
        message: 'availabilitySnapshot failed',
        error: error.toString(),
      );
    }
    log.append(
      tag: 'llm.diagnose',
      level: snapshot.error == null ? AppLogLevel.info : AppLogLevel.error,
      message:
          'readiness=${snapshot.readiness.name}; '
          'status=${snapshot.status}; reason=${snapshot.reason}; '
          'message=${snapshot.message}'
          '${snapshot.backend == null ? '' : '; backend=${snapshot.backend}'}'
          '${snapshot.platformNotes == null ? '' : '; notes=${snapshot.platformNotes}'}'
          '${snapshot.error == null ? '' : '; error=${snapshot.error}'}',
    );

    if (!probeGenerate) {
      return DiagnoseOnDeviceLlmResult(
        snapshot: snapshot,
        canGenerate: false,
        probeSkippedReason: 'probeGenerate=false',
      );
    }
    if (snapshot.readiness != OnDeviceLlmReadiness.ready) {
      final reason = 'readiness=${snapshot.readiness.name}';
      log.append(
        tag: 'llm.diagnose',
        level: AppLogLevel.warn,
        message: 'generate probe skipped ($reason)',
      );
      return DiagnoseOnDeviceLlmResult(
        snapshot: snapshot,
        canGenerate: false,
        probeSkippedReason: reason,
      );
    }

    try {
      final output = await llm.generate(probePrompt).timeout(generateTimeout);
      log.append(
        tag: 'llm.diagnose',
        level: AppLogLevel.info,
        message: 'generate probe ok length=${output.length}',
      );
      return DiagnoseOnDeviceLlmResult(
        snapshot: snapshot,
        canGenerate: output.trim().isNotEmpty,
        sampleOutput: output,
        generateError: output.trim().isEmpty ? 'empty output' : null,
      );
    } on Object catch (error) {
      log.append(
        tag: 'llm.diagnose',
        level: AppLogLevel.error,
        message: 'generate probe failed: $error',
      );
      return DiagnoseOnDeviceLlmResult(
        snapshot: snapshot,
        canGenerate: false,
        generateError: error.toString(),
      );
    }
  }
}
