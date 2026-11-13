import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';

/// メーター抽出用の固定プロンプト。
const _meterExtractPrompt =
    'You extract stationary bike meter panel values from the image.\n'
    'Reply with ONLY these lines (omit unknown):\n'
    'DISTANCE_KM=<number>\n'
    'DURATION=H:MM:SS\n'
    'CALORIES_KCAL=<number>\n'
    'AVERAGE_SPEED_KMH=<number>\n'
    'Use ASCII digits. No other text.';

/// ログに載せる LLM 生文の上限文字数。
const _maxRawChars = 500;

/// 端末上 LLM の画像生成でメーター値を取るエンジン。
///
/// 生文（切り詰め）と解析結果を [log] へ出す。
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
      prompt: _meterExtractPrompt,
      imageBytes: photoBytes,
    );
    final preview = raw.length <= _maxRawChars
        ? raw
        : '${raw.substring(0, _maxRawChars)}…';
    log.append(
      tag: 'meter.llm',
      level: raw.trim().isEmpty ? AppLogLevel.warn : AppLogLevel.info,
      message:
          'kind=${kind.name}; rawLength=${raw.length}; '
          'raw=${preview.replaceAll('\n', '\\n')}',
    );
    final values = MeterPanelTextParser.parse(raw);
    log.append(
      tag: 'meter.llm',
      level: AppLogLevel.info,
      message: 'kind=${kind.name}; parsed ${_formatValues(values)}',
    );
    return values;
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
