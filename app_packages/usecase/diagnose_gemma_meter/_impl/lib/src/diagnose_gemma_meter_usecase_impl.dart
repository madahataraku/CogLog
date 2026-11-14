import 'dart:typed_data';

import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:usecase_diagnose_gemma_meter/usecase_diagnose_gemma_meter.dart';

/// [GemmaMeterVision] の詳細と短い画像生成を診断する実装。
///
/// 測定値・生文は結果にもログにも残さない（長さと例外型名のみ）。
///
/// Example:
/// ```dart
/// DiagnoseGemmaMeterUsecaseImpl(gemma: gemma, log: AppLogStore());
/// ```
final class DiagnoseGemmaMeterUsecaseImpl implements DiagnoseGemmaMeterUsecase {
  /// [gemma] と任意の [log] / [generateTimeout] / [probePrompt] を持つ。
  ///
  /// Example:
  /// ```dart
  /// DiagnoseGemmaMeterUsecaseImpl(gemma: gemma);
  /// ```
  DiagnoseGemmaMeterUsecaseImpl({
    required this.gemma,
    AppLogStore? log,
    this.generateTimeout = const Duration(seconds: 15),
    this.probePrompt = 'Reply with exactly one short word. No other text.',
    Uint8List? probeImageBytes,
  }) : log = log ?? AppLogStore(),
       probeImageBytes = probeImageBytes ?? Uint8List(0);

  /// Gemma メーター経路。
  final GemmaMeterVision gemma;

  /// 診断経過を残すログ。
  final AppLogStore log;

  /// 準備／生成プローブの上限。
  final Duration generateTimeout;

  /// 画像プローブ用の短いプロンプト。
  final String probePrompt;

  /// 画像プローブへ渡すバイト（診断専用。空でもよい）。
  final Uint8List probeImageBytes;

  /// スナップショットを取り、準備と画像生成を試して例外型名を残す。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<DiagnoseGemmaMeterResult> execute({bool probeGenerate = true}) async {
    late final GemmaMeterAvailabilitySnapshot snapshot;
    String? availabilityError;
    try {
      snapshot = await gemma.availabilitySnapshot;
    } on Object catch (error) {
      availabilityError = formatExceptionDetail(error);
      snapshot = const GemmaMeterAvailabilitySnapshot(
        readiness: GemmaMeterReadiness.unavailable,
        status: 'error',
        reason: 'exception',
        message: 'availabilitySnapshot failed',
      );
    }
    log.append(
      tag: 'gemma.diagnose',
      level: availabilityError == null ? AppLogLevel.info : AppLogLevel.error,
      message:
          'readiness=${snapshot.readiness.name}; '
          'status=${snapshot.status}; reason=${snapshot.reason}; '
          'message=${snapshot.message}'
          '${availabilityError == null ? '' : '; error=$availabilityError'}',
    );

    String? prepareError;
    try {
      await gemma.prepareModel().last.timeout(generateTimeout);
      log.append(
        tag: 'gemma.diagnose',
        level: AppLogLevel.info,
        message: 'prepare probe ok',
      );
    } on Object catch (error) {
      prepareError = formatExceptionDetail(error);
      log.append(
        tag: 'gemma.diagnose',
        level: AppLogLevel.error,
        message: 'prepare probe failed: $prepareError',
      );
    }

    if (!probeGenerate) {
      return DiagnoseGemmaMeterResult(
        snapshot: snapshot,
        canGenerate: false,
        availabilityError: availabilityError,
        prepareError: prepareError,
        probeSkippedReason: 'probeGenerate=false',
      );
    }

    try {
      final output = await gemma
          .diagnoseGenerateWithImage(
            prompt: probePrompt,
            imageBytes: probeImageBytes,
          )
          .timeout(generateTimeout);
      final length = output.length;
      final ready = snapshot.readiness == GemmaMeterReadiness.ready;
      log.append(
        tag: 'gemma.diagnose',
        level: ready ? AppLogLevel.info : AppLogLevel.warn,
        message:
            'generate probe ok length=$length'
            '${ready ? '' : '; readiness=${snapshot.readiness.name}'}',
      );
      return DiagnoseGemmaMeterResult(
        snapshot: snapshot,
        canGenerate: output.trim().isNotEmpty,
        availabilityError: availabilityError,
        probeOutputLength: length,
        generateError: output.trim().isEmpty ? 'empty output' : null,
        prepareError: prepareError,
      );
    } on Object catch (error) {
      final detail = formatExceptionDetail(error);
      log.append(
        tag: 'gemma.diagnose',
        level: AppLogLevel.error,
        message: 'generate probe failed: $detail',
      );
      return DiagnoseGemmaMeterResult(
        snapshot: snapshot,
        canGenerate: false,
        availabilityError: availabilityError,
        generateError: detail,
        prepareError: prepareError,
      );
    }
  }
}
