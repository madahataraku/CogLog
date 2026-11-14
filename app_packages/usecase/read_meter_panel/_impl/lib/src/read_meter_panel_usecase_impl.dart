import 'dart:async';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

/// OS LLM ready+vision なら [llmEngine]、さもなければ [gemmaEngine] が available ならそれを試し、
/// どちらも無ければ手打ちへ進む。
///
/// [sessionPreference.preferGemmaOverOsLlm] が true かつ [gemmaEngine] が available のときは
/// ready+vision でも [gemmaEngine] を選ぶ。
///
/// 全体の上限は [timeout]（既定 60 秒）。
/// 超過時はその時点の結果を返す。
/// 選択理由・例外・最終値の有無は [log] へ出す（測定値・LLM 本文は出さない）。
///
/// Example:
/// ```dart
/// ReadMeterPanelUsecaseImpl(
///   llm: llm,
///   llmEngine: llmEngine,
///   gemmaEngine: gemmaEngine,
///   log: AppLogStore(),
/// ).execute(ReadMeterPanelRequest(photoBytes: Uint8List(0)));
/// ```
final class ReadMeterPanelUsecaseImpl implements ReadMeterPanelUsecase {
  /// [llm] の ready+vision 可否と [sessionPreference] でエンジンを選ぶ。
  ///
  /// Example:
  /// ```dart
  /// ReadMeterPanelUsecaseImpl(
  ///   llm: llm,
  ///   llmEngine: llmEngine,
  ///   gemmaEngine: gemmaEngine,
  ///   log: AppLogStore(),
  /// );
  /// ```
  ReadMeterPanelUsecaseImpl({
    required this.llm,
    required this.llmEngine,
    required this.gemmaEngine,
    AppLogStore? log,
    MeterReadingEngineSessionPreference? sessionPreference,
    this.timeout = const Duration(seconds: 60),
  }) : log = log ?? AppLogStore(),
       sessionPreference =
           sessionPreference ?? MeterReadingEngineSessionPreference();

  /// 準備状態と vision 可否の判定に使う。
  final OnDeviceLlm llm;

  /// OS LLM が ready+vision のとき使う読み取りエンジン。
  final MeterReadingEngine llmEngine;

  /// OS LLM が使えないときのフォールバック読み取りエンジン。
  final MeterReadingEngine gemmaEngine;

  /// デバッグ画面向けのプロセス内ログ。
  final AppLogStore log;

  /// セッション内の Gemma 優先フラグ。永続化しない。
  final MeterReadingEngineSessionPreference sessionPreference;

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
          message: 'engine fields ${_formatFieldPresence(read)}',
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
            'partial ${_formatFieldPresence(values)}',
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
      message: 'final ${_formatFieldPresence(resultValues)}',
    );
    return ReadMeterPanelResult(
      values: resultValues,
      averageSpeedFromPanel: false,
    );
  }

  /// [sessionPreference.preferGemmaOverOsLlm] かつ Gemma available なら [gemmaEngine]。
  /// さもなければ ready+vision なら [llmEngine]、さらにさもなければ Gemma available ならそれ。
  /// それ以外は null。
  ///
  /// Example:
  /// ```dart
  /// // execute 内で選択される
  /// await usecase.execute(request);
  /// ```
  Future<MeterReadingEngine?> _selectEngine() async {
    final readiness = await llm.readiness;
    final vision = await llm.supportsVision;
    final preferGemma = sessionPreference.preferGemmaOverOsLlm;
    if (preferGemma && await gemmaEngine.isAvailable) {
      log.append(
        tag: 'meter.read',
        level: AppLogLevel.info,
        message:
            'select gemma kind=${gemmaEngine.kind.name}; '
            'reason=debug_prefer_gemma; '
            'readiness=${readiness.name}; vision=$vision',
      );
      return gemmaEngine;
    }
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
    if (await gemmaEngine.isAvailable) {
      log.append(
        tag: 'meter.read',
        level: AppLogLevel.info,
        message:
            'select gemma kind=${gemmaEngine.kind.name}; '
            'reason=os_llm_unavailable; '
            'readiness=${readiness.name}; vision=$vision',
      );
      return gemmaEngine;
    }
    log.append(
      tag: 'meter.read',
      level: AppLogLevel.warn,
      message:
          'no engine; readiness=${readiness.name}; vision=$vision; '
          'gemmaUnavailable; preferGemma=$preferGemma',
    );
    return null;
  }
}

/// [values] の各フィールド有無だけをログ向けにする（数値は出さない）。
///
/// Example:
/// ```dart
/// _formatFieldPresence(const MeterReadingValues(distanceKm: 1));
/// ```
String _formatFieldPresence(MeterReadingValues values) {
  final present = <String>[];
  final missing = <String>[];
  void classify(String name, Object? value) {
    if (value == null) {
      missing.add(name);
    } else {
      present.add(name);
    }
  }

  classify('distanceKm', values.distanceKm);
  classify('duration', values.duration);
  classify('caloriesKcal', values.caloriesKcal);
  classify('averageSpeedKmh', values.averageSpeedKmh);
  return 'present=[${present.join(',')}]; missing=[${missing.join(',')}]';
}
