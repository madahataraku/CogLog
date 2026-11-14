import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

import 'meter_extract_prompt.dart';
import 'meter_reading_field_presence.dart';

/// Gemma E2B の画像生成でメーター値を取るエンジン。
///
/// 生文の長さと解析フィールドの有無だけを [log] へ出す（測定値・生文は出さない）。
///
/// Example:
/// ```dart
/// GemmaMeterReadingEngine(
///   gemma: gemma,
///   log: AppLogStore(),
/// );
/// ```
final class GemmaMeterReadingEngine implements MeterReadingEngine {
  /// [gemma] と任意の [log] を持つ Gemma エンジンを作る。
  ///
  /// Example:
  /// ```dart
  /// GemmaMeterReadingEngine(
  ///   gemma: gemma,
  ///   log: AppLogStore(),
  /// );
  /// ```
  GemmaMeterReadingEngine({required this.gemma, AppLogStore? log})
    : log = log ?? AppLogStore();

  /// 常に [MeterReadingEngineKind.gemmaE2b]。
  ///
  /// Example:
  /// ```dart
  /// engine.kind;
  /// ```
  @override
  MeterReadingEngineKind get kind => MeterReadingEngineKind.gemmaE2b;

  /// 画像付き生成の窓口。
  final GemmaMeterVision gemma;

  /// デバッグ画面向けのプロセス内ログ。
  final AppLogStore log;

  /// [gemma] が利用可能のとき true。
  ///
  /// Example:
  /// ```dart
  /// await engine.isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async => gemma.isAvailable;

  /// [photoBytes] を画像付き生成し [MeterPanelTextParser.parse] する。
  ///
  /// Example:
  /// ```dart
  /// await engine.read(Uint8List(0));
  /// ```
  @override
  Future<MeterReadingValues> read(Uint8List photoBytes) async {
    final raw = await gemma.generateWithImage(
      prompt: meterExtractPrompt,
      imageBytes: photoBytes,
    );
    log.append(
      tag: 'meter.gemma',
      level: raw.trim().isEmpty ? AppLogLevel.warn : AppLogLevel.info,
      message: 'kind=${kind.name}; rawLength=${raw.length}',
    );
    final values = MeterPanelTextParser.parse(raw);
    log.append(
      tag: 'meter.gemma',
      level: AppLogLevel.info,
      message:
          'kind=${kind.name}; parsed ${formatMeterReadingFieldPresence(values)}',
    );
    return values;
  }
}
