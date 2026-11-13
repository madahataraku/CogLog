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
    MeterSevenSegmentRecognizer? sevenSegmentRecognizer,
    AppLogStore? log,
  }) : sevenSegmentRecognizer =
           sevenSegmentRecognizer ?? const _EmptySevenSegmentRecognizer(),
       log = log ?? AppLogStore();

  /// エンジン種別（iOS は visionOcr、Android は mlKit）。
  @override
  final MeterReadingEngineKind kind;

  /// 座標付き認識の実装。
  final MeterLayoutRecognizer recognizer;

  /// 七セグ数値候補。省略時は空認識器。
  final MeterSevenSegmentRecognizer sevenSegmentRecognizer;

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
    final genericTokens = await recognizer.recognizeLayout(photoBytes);
    final kindCounts = MeterSpatialLayoutInferencer.classifyKindCounts(
      genericTokens,
    );
    final otherDigits = MeterSpatialLayoutInferencer.countOtherWithDigits(
      genericTokens,
    );
    log.append(
      tag: 'meter.spatial',
      level: genericTokens.isEmpty ? AppLogLevel.warn : AppLogLevel.info,
      message:
          'kind=${kind.name}; tokens=${genericTokens.length}; '
          'classes=${_formatKindCounts(kindCounts)}; '
          'otherDigits=$otherDigits',
    );

    var sevenSegTokens = const <MeterOcrToken>[];
    var sevenSegError = false;
    try {
      sevenSegTokens = await sevenSegmentRecognizer.recognize(photoBytes);
    } on Object catch (e, st) {
      // 七セグは補完経路。初期化失敗・ネイティブ例外でも汎用結果で完了させる。
      // Error / Exception の両方を握り、呼び出し側を落とさない。
      sevenSegError = true;
      sevenSegTokens = const [];
      assert(() {
        return e.toString().isNotEmpty || st.toString().isNotEmpty;
      }());
    }
    log.append(
      tag: 'meter.spatial',
      level: AppLogLevel.info,
      message:
          'sevenSeg candidates=${sevenSegTokens.length}; '
          'error=$sevenSegError',
    );

    final valuesGeneric = MeterSpatialLayoutInferencer.infer(genericTokens);
    final anchorTokens =
        MeterSpatialLayoutInferencer.tokensExcludingNumericValues(
          genericTokens,
        );
    // 汎用で数値として確定した矩形と重なる七セグ候補は別項目へ流用しない。
    final numericGeneric = [
      for (final t in genericTokens)
        if (!anchorTokens.contains(t)) t,
    ];
    final sevenSegForInfer = [
      for (final s in sevenSegTokens)
        if (!_overlapsAny(s, numericGeneric)) s,
    ];
    final valuesSeven = MeterSpatialLayoutInferencer.infer([
      ...anchorTokens,
      ...sevenSegForInfer,
    ]);
    final values = MeterReadingMerger.preferFirst(valuesGeneric, valuesSeven);
    log.append(
      tag: 'meter.spatial',
      level: AppLogLevel.info,
      message:
          'kind=${kind.name}; inferred ${_formatFieldPresence(values)}; '
          'adoptedFromSevenSeg=${_formatAdoptedFromSeven(valuesGeneric, values)}',
    );
    return values;
  }
}

/// 七セグを使わず空列だけ返す認識器（テスト／未注入用）。
final class _EmptySevenSegmentRecognizer
    implements MeterSevenSegmentRecognizer {
  /// 空認識器を作る。
  ///
  /// Example:
  /// ```dart
  /// const _EmptySevenSegmentRecognizer();
  /// ```
  const _EmptySevenSegmentRecognizer();

  /// 常に空列を返す。
  ///
  /// Example:
  /// ```dart
  /// await const _EmptySevenSegmentRecognizer().recognize(Uint8List(0));
  /// ```
  @override
  Future<List<MeterOcrToken>> recognize(Uint8List photoBytes) async => const [];

  /// 解放対象はない。
  ///
  /// Example:
  /// ```dart
  /// await const _EmptySevenSegmentRecognizer().close();
  /// ```
  @override
  Future<void> close() async {}
}

/// [candidate] が [regions] のいずれかの矩形と交差するか。
bool _overlapsAny(MeterOcrToken candidate, List<MeterOcrToken> regions) {
  for (final r in regions) {
    final left = candidate.left > r.left ? candidate.left : r.left;
    final top = candidate.top > r.top ? candidate.top : r.top;
    final right = (candidate.left + candidate.width) < (r.left + r.width)
        ? candidate.left + candidate.width
        : r.left + r.width;
    final bottom = (candidate.top + candidate.height) < (r.top + r.height)
        ? candidate.top + candidate.height
        : r.top + r.height;
    if (right > left && bottom > top) {
      return true;
    }
  }
  return false;
}

/// 汎用で欠け、結果で埋まったフィールド名だけを列挙する（数値は出さない）。
///
/// Example:
/// ```dart
/// _formatAdoptedFromSeven(
///   const MeterReadingValues(),
///   const MeterReadingValues(distanceKm: 1),
/// );
/// ```
String _formatAdoptedFromSeven(
  MeterReadingValues generic,
  MeterReadingValues merged,
) {
  final names = <String>[];
  if (generic.distanceKm == null && merged.distanceKm != null) {
    names.add('distanceKm');
  }
  if (generic.duration == null && merged.duration != null) {
    names.add('duration');
  }
  if (generic.caloriesKcal == null && merged.caloriesKcal != null) {
    names.add('caloriesKcal');
  }
  return '[${names.join(',')}]';
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
