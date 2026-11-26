import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

import 'meter_extract_prompt.dart';
import 'meter_reading_field_presence.dart';

/// LFM VL の画像生成でメーター値を取るエンジン。
///
/// 生文の長さと解析フィールドの有無だけを [log] へ出す（測定値・生文は出さない）。
///
/// Example:
/// ```dart
/// MeterVlReadingEngine(
///   meterVl: meterVl,
///   log: AppLogStore(),
/// );
/// ```
final class MeterVlReadingEngine implements MeterReadingEngine {
  /// [meterVl] と任意の [log] を持つ LFM VL エンジンを作る。
  ///
  /// Example:
  /// ```dart
  /// MeterVlReadingEngine(
  ///   meterVl: meterVl,
  ///   log: AppLogStore(),
  /// );
  /// ```
  MeterVlReadingEngine({required this.meterVl, AppLogStore? log})
    : log = log ?? AppLogStore();

  /// 常に [MeterReadingEngineKind.lfmVl]。
  ///
  /// Example:
  /// ```dart
  /// engine.kind;
  /// ```
  @override
  MeterReadingEngineKind get kind => MeterReadingEngineKind.lfmVl;

  /// 画像付き生成の窓口。
  final MeterVlVision meterVl;

  /// デバッグ画面向けのプロセス内ログ。
  final AppLogStore log;

  /// [meterVl] が利用可能のとき true。
  ///
  /// Example:
  /// ```dart
  /// await engine.isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async => meterVl.isAvailable;

  /// [photoBytes] を画像付き生成し [MeterPanelTextParser.parse] する。
  ///
  /// Example:
  /// ```dart
  /// await engine.read(Uint8List(0));
  /// ```
  @override
  Future<MeterReadingValues> read(Uint8List photoBytes) async {
    final raw = await meterVl.generateWithImage(
      prompt: meterExtractPrompt,
      imageBytes: photoBytes,
    );
    log.append(
      tag: 'meter.lfm',
      level: raw.trim().isEmpty ? AppLogLevel.warn : AppLogLevel.info,
      message: 'kind=${kind.name}; rawLength=${raw.length}',
    );
    final values = MeterPanelTextParser.parse(raw);
    log.append(
      tag: 'meter.lfm',
      level: AppLogLevel.info,
      message:
          'kind=${kind.name}; parsed ${formatMeterReadingFieldPresence(values)}',
    );
    return values;
  }
}
