import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';

import 'meter_extract_prompt.dart';
import 'meter_reading_field_presence.dart';

/// 端末上 LLM の画像生成でメーター値を取るエンジン。
///
/// 生文の長さと解析フィールドの有無だけを [log] へ出す（測定値・生文は出さない）。
///
/// Example:
/// ```dart
/// LlmMeterReadingEngine(
///   kind: MeterReadingEngineKind.geminiNano,
///   llm: llm,
///   log: AppLogStore(),
/// );
/// ```
final class LlmMeterReadingEngine implements MeterReadingEngine {
  /// [kind] と [llm] を持つ LLM エンジンを作る。
  ///
  /// [requireVision] が true のとき [OnDeviceLlm.supportsVision] も見る。
  ///
  /// Example:
  /// ```dart
  /// LlmMeterReadingEngine(
  ///   kind: MeterReadingEngineKind.foundationModel,
  ///   llm: llm,
  ///   log: AppLogStore(),
  /// );
  /// ```
  LlmMeterReadingEngine({
    required this.kind,
    required this.llm,
    this.requireVision = true,
    AppLogStore? log,
  }) : log = log ?? AppLogStore();

  /// エンジン種別（iOS は foundationModel、Android は geminiNano）。
  @override
  final MeterReadingEngineKind kind;

  /// 画像付き生成の窓口。
  final OnDeviceLlm llm;

  /// true のとき vision 非対応なら利用不可とする。
  final bool requireVision;

  /// デバッグ画面向けのプロセス内ログ。
  final AppLogStore log;

  /// [llm] が利用可能で、必要なら vision 対応のとき true。
  ///
  /// Example:
  /// ```dart
  /// await engine.isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async {
    if (!await llm.isAvailable) {
      return false;
    }
    if (requireVision && !await llm.supportsVision) {
      return false;
    }
    return true;
  }

  /// [photoBytes] を画像付き生成し [MeterPanelTextParser.parse] する。
  ///
  /// Example:
  /// ```dart
  /// await engine.read(Uint8List(0));
  /// ```
  @override
  Future<MeterReadingValues> read(Uint8List photoBytes) async {
    final raw = await llm.generateWithImage(
      prompt: meterExtractPrompt,
      imageBytes: photoBytes,
    );
    log.append(
      tag: 'meter.llm',
      level: raw.trim().isEmpty ? AppLogLevel.warn : AppLogLevel.info,
      message: 'kind=${kind.name}; rawLength=${raw.length}',
    );
    final values = MeterPanelTextParser.parse(raw);
    log.append(
      tag: 'meter.llm',
      level: AppLogLevel.info,
      message:
          'kind=${kind.name}; parsed ${formatMeterReadingFieldPresence(values)}',
    );
    return values;
  }
}
