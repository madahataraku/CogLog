import 'dart:async';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_debug_overrides/foundation_debug_overrides.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

/// LLM ready なら LLM のみ、それ以外は空間 OCR のみを試す（併用しない）。
///
/// デバッグの空間 OCR 強制が ON のときは LLM ready でも空間 OCR のみとし、
/// 使えなければ手打ちへ進む（LLM には戻さない）。
/// 全体の上限は [timeout]（既定 30 秒）。超過時はその時点の結果を返す。
///
/// Example:
/// ```dart
/// ReadMeterPanelUsecaseImpl(
///   llm: llm,
///   llmEngine: llmEngine,
///   spatialEngine: spatialEngine,
///   forceSpatialOcr: ForceSpatialOcrStore(),
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
  /// );
  /// ```
  const ReadMeterPanelUsecaseImpl({
    required this.llm,
    required this.llmEngine,
    required this.spatialEngine,
    required this.forceSpatialOcr,
    this.timeout = const Duration(seconds: 30),
  });

  /// 準備状態と vision 可否の判定に使う。
  final OnDeviceLlm llm;

  /// LLM 読み取りエンジン。
  final MeterReadingEngine llmEngine;

  /// 空間 OCR エンジン。
  final MeterReadingEngine spatialEngine;

  /// デバッグ用の空間 OCR 強制フラグ。
  final ForceSpatialOcrStore forceSpatialOcr;

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
        return const MeterReadingValues();
      }
      try {
        if (!await engine.isAvailable) {
          return const MeterReadingValues();
        }
        return await engine.read(request.photoBytes);
      } on Object {
        return const MeterReadingValues();
      }
    }

    try {
      values = await runSelected().timeout(timeout);
    } on TimeoutException {
      // その時点の values を使う。
    }

    final resolved = resolveInitialAverageSpeed(merged: values);
    return ReadMeterPanelResult(
      values: MeterReadingValues(
        distanceKm: values.distanceKm,
        duration: values.duration,
        caloriesKcal: values.caloriesKcal,
        averageSpeedKmh: resolved.speed,
      ),
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
        return spatialEngine;
      }
      return null;
    }
    final readiness = await llm.readiness;
    final vision = await llm.supportsVision;
    if (readiness == OnDeviceLlmReadiness.ready && vision) {
      return llmEngine;
    }
    if (await spatialEngine.isAvailable) {
      return spatialEngine;
    }
    return null;
  }
}
