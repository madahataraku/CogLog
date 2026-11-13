import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// 座標付き OCR と空間推論でメーター値を取るエンジン。
///
/// 認識トークン数・分類件数・推論フィールドの有無だけを [log] へ出す。
/// 測定値・トークン本文は出さない。
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
    final kindCounts = MeterSpatialLayoutInferencer.classifyKindCounts(tokens);
    log.append(
      tag: 'meter.spatial',
      level: tokens.isEmpty ? AppLogLevel.warn : AppLogLevel.info,
      message:
          'kind=${kind.name}; tokens=${tokens.length}; '
          'classes=${_formatKindCounts(kindCounts)}',
    );
    final values = MeterSpatialLayoutInferencer.infer(tokens);
    log.append(
      tag: 'meter.spatial',
      level: AppLogLevel.info,
      message: 'kind=${kind.name}; inferred ${_formatFieldPresence(values)}',
    );
    return values;
  }
}

/// 分類件数を `name:count` の昇順連結にする。
///
/// Example:
/// ```dart
/// _formatKindCounts({'other': 2, 'bareNumber': 1});
/// ```
String _formatKindCounts(Map<String, int> counts) {
  if (counts.isEmpty) {
    return '[]';
  }
  final keys = counts.keys.toList()..sort();
  return '[${keys.map((k) => '$k:${counts[k]}').join(',')}]';
}

/// [values] の各フィールド有無だけをログ向けにする（数値は出さない）。
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
