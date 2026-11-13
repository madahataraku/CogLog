import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// 座標付き OCR と空間推論でメーター値を取るエンジン。
///
/// 認識トークン数・本文サンプル・推論結果を [log] へ出す。
///
/// Example:
/// ```dart
/// SpatialOcrMeterReadingEngine(
///   kind: MeterReadingEngineKind.visionOcr,
///   recognizer: recognizer,
///   log: AppLogStore(),
/// );
/// ```
final class SpatialOcrMeterReadingEngine implements MeterReadingEngine {
  /// [kind] と [recognizer] を持つ空間 OCR エンジンを作る。
  ///
  /// Example:
  /// ```dart
  /// SpatialOcrMeterReadingEngine(
  ///   kind: MeterReadingEngineKind.mlKit,
  ///   recognizer: recognizer,
  ///   log: AppLogStore(),
  /// );
  /// ```
  SpatialOcrMeterReadingEngine({
    required this.kind,
    required this.recognizer,
    AppLogStore? log,
  }) : log = log ?? AppLogStore();

  /// エンジン種別（iOS は visionOcr、Android は mlKit）。
  @override
  final MeterReadingEngineKind kind;

  /// 座標付き認識の実装。
  final MeterLayoutRecognizer recognizer;

  /// デバッグ画面向けのプロセス内ログ。
  final AppLogStore log;

  /// ログに載せるトークン本文の上限件数。
  static const int _maxLoggedTokens = 40;

  /// 1 トークン本文の切り詰め文字数。
  static const int _maxTokenChars = 40;

  /// モバイルでは常に試す。失敗は [read] の例外として呼び出し側が握る。
  ///
  /// Example:
  /// ```dart
  /// await engine.isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async => true;

  /// [photoBytes] を認識し空間推論する。
  ///
  /// Example:
  /// ```dart
  /// await engine.read(Uint8List(0));
  /// ```
  @override
  Future<MeterReadingValues> read(Uint8List photoBytes) async {
    final tokens = await recognizer.recognizeLayout(photoBytes);
    log.append(
      tag: 'meter.spatial',
      level: tokens.isEmpty ? AppLogLevel.warn : AppLogLevel.info,
      message:
          'kind=${kind.name}; tokens=${tokens.length}; '
          'texts=[${_formatTokenTexts(tokens)}]',
    );
    final values = MeterSpatialLayoutInferencer.infer(tokens);
    log.append(
      tag: 'meter.spatial',
      level: AppLogLevel.info,
      message: 'kind=${kind.name}; inferred ${_formatValues(values)}',
    );
    return values;
  }
}

/// [tokens] の本文をログ向けに要約する。
String _formatTokenTexts(List<MeterOcrToken> tokens) {
  if (tokens.isEmpty) {
    return '';
  }
  final shown = tokens.take(SpatialOcrMeterReadingEngine._maxLoggedTokens);
  final parts = [for (final token in shown) _truncate(token.text)];
  final joined = parts.join(' | ');
  if (tokens.length > SpatialOcrMeterReadingEngine._maxLoggedTokens) {
    return '$joined | …(+${tokens.length - SpatialOcrMeterReadingEngine._maxLoggedTokens})';
  }
  return joined;
}

/// [text] を [_maxTokenChars] で切り詰める。
String _truncate(String text) {
  if (text.length <= SpatialOcrMeterReadingEngine._maxTokenChars) {
    return text;
  }
  return '${text.substring(0, SpatialOcrMeterReadingEngine._maxTokenChars)}…';
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
