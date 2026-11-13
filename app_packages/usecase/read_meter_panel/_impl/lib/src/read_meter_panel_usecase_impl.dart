import 'dart:async';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:foundation_debug_overrides/foundation_debug_overrides.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

/// LLM ready なら LLM のみ、それ以外は空間 OCR のみを試す（併用しない）。
///
/// デバッグの空間 OCR 強制が ON のときは LLM ready でも空間 OCR のみとし、
/// 使えなければ手打ちへ進む（LLM には戻さない）。
/// 全体の上限は [timeout]（既定 30 秒）。超過時はその時点の結果を返す。
/// 選択理由・例外・最終値は [log] へ出す。
///
/// Example:
/// ```dart
/// ReadMeterPanelUsecaseImpl(
///   llm: llm,
///   llmEngine: llmEngine,
///   spatialEngine: spatialEngine,
///   forceSpatialOcr: ForceSpatialOcrStore(),
///   log: AppLogStore(),
/// ).execute(ReadMeterPanelRequest(photoBytes: Uint8List(0)));
/// ```
final class ReadMeterPanelUsecaseImpl implements ReadMeterPanelUsecase {
  /// [forceSpatialOcr] と [llm] の可否で [llmEngine] / [spatialEngine] を排他選択する。
  ///
  /// Example:
  /// ```dart
  /// ReadMeterPanelUsecaseImpl(
  ///   llm: llm,
  ///   llmEngine: llmEngine,
  ///   spatialEngine: spatialEngine,
  ///   forceSpatialOcr: ForceSpatialOcrStore(),
  ///   log: AppLogStore(),
  /// );
  /// ```
  ReadMeterPanelUsecaseImpl({
    required this.llm,
    required this.llmEngine,
    required this.spatialEngine,
    required this.forceSpatialOcr,
    AppLogStore? log,
    this.timeout = const Duration(seconds: 30),
  }) : log = log ?? AppLogStore();

  /// 準備状態と vision 可否の判定に使う。
  final OnDeviceLlm llm;

  /// LLM 読み取りエンジン。
  final MeterReadingEngine llmEngine;

  /// 空間 OCR エンジン。
  final MeterReadingEngine spatialEngine;

  /// デバッグ用の空間 OCR 強制フラグ。
  final ForceSpatialOcrStore forceSpatialOcr;

  /// デバッグ画面向けのプロセス内ログ。
  final AppLogStore log;

  /// 読み取り全体の上限。
  final Duration timeout;

  /// [request] の写真を読み、初期平均速度を埋めて返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(ReadMeterPanelRequest(photoBytes: Uint8List(0)));
  /// ```
  @override
  Future<ReadMeterPanelResult> execute(ReadMeterPanelRequest request) async {
    var values = const MeterReadingValues();

    Future<MeterReadingValues> runSelected() async {
      final engine = await _selectEngine();
      if (engine == null) {
        log.append(
          tag: 'meter.read',
          level: AppLogLevel.warn,
          message: 'no engine selected',
        );
        return const MeterReadingValues();
      }
      try {
        if (!await engine.isAvailable) {
          log.append(
            tag: 'meter.read',
            level: AppLogLevel.warn,
            message: 'engine unavailable kind=${engine.kind.name}',
          );
          return const MeterReadingValues();
        }
        log.append(
          tag: 'meter.read',
          level: AppLogLevel.info,
          message: 'reading kind=${engine.kind.name}',
        );
        final read = await engine.read(request.photoBytes);
        log.append(
          tag: 'meter.read',
          level: AppLogLevel.info,
          message: 'engine values ${_formatValues(read)}',
        );
        return read;
      } on Object catch (error) {
        log.append(
          tag: 'meter.read',
          level: AppLogLevel.error,
          message:
              'engine failed kind=${engine.kind.name}: '
              '${formatExceptionDetail(error)}',
        );
        return const MeterReadingValues();
      }
    }

    try {
      values = await runSelected().timeout(timeout);
    } on TimeoutException {
      log.append(
        tag: 'meter.read',
        level: AppLogLevel.warn,
        message:
            'timeout after ${timeout.inSeconds}s; '
            'partial ${_formatValues(values)}',
      );
    }

    final resolved = resolveInitialAverageSpeed(merged: values);
    final resultValues = MeterReadingValues(
      distanceKm: values.distanceKm,
      duration: values.duration,
      caloriesKcal: values.caloriesKcal,
      averageSpeedKmh: resolved.speed,
    );
    log.append(
      tag: 'meter.read',
      level: AppLogLevel.info,
      message: 'final ${_formatValues(resultValues)}',
    );
    return ReadMeterPanelResult(
      values: resultValues,
      averageSpeedFromPanel: false,
    );
  }

  /// 強制 ON なら空間 OCR のみ。通常は ready+vision なら LLM、それ以外は空間 OCR。
  ///
  /// Example:
  /// ```dart
  /// // execute 内で選択される
  /// await usecase.execute(request);
  /// ```
  Future<MeterReadingEngine?> _selectEngine() async {
    if (forceSpatialOcr.enabled) {
      if (await spatialEngine.isAvailable) {
        log.append(
          tag: 'meter.read',
          level: AppLogLevel.info,
          message:
              'select spatial kind=${spatialEngine.kind.name}; '
              'reason=forceSpatialOcr',
        );
        return spatialEngine;
      }
      log.append(
        tag: 'meter.read',
        level: AppLogLevel.warn,
        message: 'forceSpatialOcr on but spatial unavailable',
      );
      return null;
    }
    final readiness = await llm.readiness;
    final vision = await llm.supportsVision;
    if (readiness == OnDeviceLlmReadiness.ready && vision) {
      log.append(
        tag: 'meter.read',
        level: AppLogLevel.info,
        message:
            'select llm kind=${llmEngine.kind.name}; '
            'reason=ready+vision; readiness=${readiness.name}',
      );
      return llmEngine;
    }
    if (await spatialEngine.isAvailable) {
      log.append(
        tag: 'meter.read',
        level: AppLogLevel.info,
        message:
            'select spatial kind=${spatialEngine.kind.name}; '
            'reason=llm_not_ready_or_no_vision; '
            'readiness=${readiness.name}; vision=$vision',
      );
      return spatialEngine;
    }
    log.append(
      tag: 'meter.read',
      level: AppLogLevel.warn,
      message:
          'no engine; readiness=${readiness.name}; vision=$vision; '
          'spatial unavailable',
    );
    return null;
  }
}

/// [values] を 1 行のログ向け文字列にする。
String _formatValues(MeterReadingValues values) {
  final duration = values.duration;
  final durationText = duration == null ? 'null' : '${duration.inSeconds}s';
  return 'distanceKm=${values.distanceKm}; '
      'duration=$durationText; '
      'caloriesKcal=${values.caloriesKcal}; '
      'averageSpeedKmh=${values.averageSpeedKmh}';
}
