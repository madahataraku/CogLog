import 'dart:async';
import 'dart:typed_data';

import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:usecase_diagnose_meter_vl/usecase_diagnose_meter_vl.dart';

/// [MeterVlVision] の詳細と短い画像生成を診断する実装。
///
/// 測定値・生文は結果にもログにも残さない（長さと例外型名のみ）。
///
/// Example:
/// ```dart
/// DiagnoseMeterVlUsecaseImpl(meterVl: meterVl, log: AppLogStore());
/// ```
final class DiagnoseMeterVlUsecaseImpl implements DiagnoseMeterVlUsecase {
  /// [meterVl] と任意の [log] / [generateTimeout] / [probePrompt] を持つ。
  ///
  /// Example:
  /// ```dart
  /// DiagnoseMeterVlUsecaseImpl(meterVl: meterVl);
  /// ```
  DiagnoseMeterVlUsecaseImpl({
    required this.meterVl,
    AppLogStore? log,
    this.generateTimeout = const Duration(seconds: 15),
    this.probePrompt = 'Reply with exactly one short word. No other text.',
    Uint8List? probeImageBytes,
  }) : log = log ?? AppLogStore(),
       probeImageBytes = probeImageBytes ?? Uint8List(0);

  /// メーター VL経路。
  final MeterVlVision meterVl;

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
  Future<DiagnoseMeterVlResult> execute({bool probeGenerate = true}) async {
    late final MeterVlAvailabilitySnapshot snapshot;
    String? availabilityError;
    try {
      snapshot = await meterVl.availabilitySnapshot;
    } on Object catch (error) {
      availabilityError = formatExceptionDetail(error);
      snapshot = const MeterVlAvailabilitySnapshot(
        readiness: MeterVlReadiness.unavailable,
        status: 'error',
        reason: 'exception',
        message: 'availabilitySnapshot failed',
      );
    }
    log.append(
      tag: 'meterVl.diagnose',
      level: availabilityError == null ? AppLogLevel.info : AppLogLevel.error,
      message:
          'readiness=${snapshot.readiness.name}; '
          'status=${snapshot.status}; reason=${snapshot.reason}; '
          'message=${snapshot.message}; '
          'backend=${snapshot.backend}; '
          'visionBackend=${snapshot.visionBackend}'
          '${availabilityError == null ? '' : '; error=$availabilityError'}',
    );

    String? prepareError;
    // last.timeout だけでは購読が残るため、明示購読して finally で解除する。
    // ネイティブ準備の停止は購読解除とは別（クライアント onCancel へ委譲）。
    StreamSubscription<double>? prepareSubscription;
    try {
      final done = Completer<void>();
      prepareSubscription = meterVl.prepareModel().listen(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          if (!done.isCompleted) {
            done.completeError(error, stackTrace);
          }
        },
        onDone: () {
          if (!done.isCompleted) {
            done.complete();
          }
        },
        cancelOnError: true,
      );
      await done.future.timeout(generateTimeout);
      log.append(
        tag: 'meterVl.diagnose',
        level: AppLogLevel.info,
        message: 'prepare probe ok',
      );
    } on Object catch (error) {
      prepareError = formatExceptionDetail(error);
      log.append(
        tag: 'meterVl.diagnose',
        level: AppLogLevel.error,
        message: 'prepare probe failed: $prepareError',
      );
    } finally {
      // 完了済み購読の cancel Future を await すると、Flutter Widget テストの
      // fake async で後続 Future が完了しなくなる。onCancel は呼び出し時に走る。
      final subscription = prepareSubscription;
      if (subscription != null) {
        unawaited(
          subscription.cancel().catchError((Object error) {
            log.append(
              tag: 'meterVl.diagnose',
              level: AppLogLevel.error,
              message: 'prepare cancel failed: ${formatExceptionDetail(error)}',
            );
          }),
        );
      }
    }

    if (!probeGenerate) {
      return DiagnoseMeterVlResult(
        snapshot: snapshot,
        canGenerate: false,
        availabilityError: availabilityError,
        prepareError: prepareError,
        probeSkippedReason: 'probeGenerate=false',
      );
    }

    try {
      final output = await meterVl
          .diagnoseGenerateWithImage(
            prompt: probePrompt,
            imageBytes: probeImageBytes,
          )
          .timeout(generateTimeout);
      final length = output.length;
      final ready = snapshot.readiness == MeterVlReadiness.ready;
      log.append(
        tag: 'meterVl.diagnose',
        level: ready ? AppLogLevel.info : AppLogLevel.warn,
        message:
            'generate probe ok length=$length'
            '${ready ? '' : '; readiness=${snapshot.readiness.name}'}',
      );
      return DiagnoseMeterVlResult(
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
        tag: 'meterVl.diagnose',
        level: AppLogLevel.error,
        message: 'generate probe failed: $detail',
      );
      return DiagnoseMeterVlResult(
        snapshot: snapshot,
        canGenerate: false,
        availabilityError: availabilityError,
        generateError: detail,
        prepareError: prepareError,
      );
    }
  }
}
