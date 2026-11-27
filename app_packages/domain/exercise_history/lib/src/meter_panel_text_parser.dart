import 'dart:convert';

import 'meter_duration_parser.dart';
import 'meter_reading_values.dart';

/// OCR／LLM の生テキストからメーター計測値を取り出す。
///
/// JSON（`distance` / `time-hour` / `time-min` / `time-sec` / `calories`）を優先し、
/// 取れないときは従来のラベル付き断片へフォールバックする。
///
/// Example:
/// ```dart
/// MeterPanelTextParser.parse('{"distance":12.3,"time-hour":1,"time-min":0,"time-sec":0,"calories":200}');
/// ```
abstract final class MeterPanelTextParser {
  /// 項目ラベル（次ラベル境界の検出にも使う）。
  static const _boundaryLabels = [
    'distance_km',
    'average_speed_kmh',
    'calories_kcal',
    'average_speed',
    'duration',
    'distance',
    'calorie',
    'calories',
    'speed',
    'time',
    '走行距離',
    '平均速度',
    '消費カロリー',
    '運動時間',
    'カロリー',
    '距離',
    '速度',
    '時間',
    '消費',
  ];

  /// [rawText] から読めた項目だけを返す。不正値は未取得。
  ///
  /// Example:
  /// ```dart
  /// MeterPanelTextParser.parse('距離 12.3 km');
  /// ```
  static MeterReadingValues parse(String rawText) {
    final fromJson = _tryParseJson(rawText);
    if (fromJson != null) {
      return fromJson;
    }
    return _parseLabeledText(rawText);
  }

  /// JSON 応答を試し、軽微な破損は修復してから読む。
  ///
  /// Example:
  /// ```dart
  /// _tryParseJson('{"distance": 5,}');
  /// ```
  static MeterReadingValues? _tryParseJson(String rawText) {
    final candidates = _jsonCandidates(rawText);
    for (final candidate in candidates) {
      final decoded = _decodeJsonObject(candidate);
      if (decoded == null) {
        continue;
      }
      return _valuesFromJsonMap(decoded);
    }
    return null;
  }

  /// 生文から JSON っぽい候補文字列を列挙する。
  static List<String> _jsonCandidates(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) {
      return const [];
    }
    final candidates = <String>{};
    candidates.add(trimmed);

    final fenced = RegExp(
      r'```(?:json)?\s*([\s\S]*?)```',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (fenced != null) {
      candidates.add(fenced.group(1)!.trim());
    }

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start != -1 && end > start) {
      candidates.add(trimmed.substring(start, end + 1));
    } else if (start != -1) {
      candidates.add(trimmed.substring(start));
    }
    return candidates.toList(growable: false);
  }

  /// 破損しやすい箇所を直しながら [Map] へデコードする。
  static Map<String, Object?>? _decodeJsonObject(String source) {
    var current = source.trim();
    for (var attempt = 0; attempt < 4; attempt++) {
      try {
        final decoded = jsonDecode(current);
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
        return null;
      } on FormatException {
        final repaired = _repairJson(current);
        if (repaired == current) {
          return null;
        }
        current = repaired;
      }
    }
    return null;
  }

  /// よくある JSON 破損を軽く直す。
  ///
  /// Example:
  /// ```dart
  /// _repairJson("{'distance': 1,}");
  /// ```
  static String _repairJson(String source) {
    var text = source.trim();
    text = text
        .replaceAll('\u201c', '"')
        .replaceAll('\u201d', '"')
        .replaceAll('\u2018', "'")
        .replaceAll('\u2019', "'");
    text = text.replaceAllMapped(
      RegExp(r',\s*([}\]])'),
      (match) => match.group(1)!,
    );
    text = text.replaceAllMapped(
      RegExp(r"'([^'\\]*(?:\\.[^'\\]*)*)'"),
      (match) => '"${match.group(1)!}"',
    );
    text = text.replaceAllMapped(
      RegExp(r'([{,]\s*)([A-Za-z_][\w-]*)(\s*:)'),
      (match) => '${match.group(1)}"${match.group(2)}"${match.group(3)}',
    );
    text = text.replaceAllMapped(
      RegExp(
        r'''((?:"(?:\\.|[^"\\])*"|-?\d+(?:\.\d+)?|true|false|null))\s+(?=")''',
      ),
      (match) => '${match.group(1)}, ',
    );
    final open = '{'.allMatches(text).length;
    final close = '}'.allMatches(text).length;
    if (open > close) {
      text = '$text${'}' * (open - close)}';
    }
    return text;
  }

  /// JSON マップから計測値を組み立てる。
  static MeterReadingValues _valuesFromJsonMap(Map<String, Object?> map) {
    final distance = _plausibleNumber(map['distance']);
    final calories = _plausibleNumber(map['calories']);
    final hours = _nonNegativeInt(map['time-hour']);
    final minutes = _nonNegativeInt(map['time-min']);
    final seconds = _nonNegativeInt(map['time-sec']);
    Duration? duration;
    if (hours != null || minutes != null || seconds != null) {
      duration = Duration(
        hours: hours ?? 0,
        minutes: minutes ?? 0,
        seconds: seconds ?? 0,
      );
    }
    return MeterReadingValues(
      distanceKm: distance,
      duration: duration,
      caloriesKcal: calories,
    );
  }

  /// 有限かつ妥当な数値だけを返す。
  static double? _plausibleNumber(Object? raw) {
    final value = _asDouble(raw);
    if (value == null || !_isPlausibleMetric(value)) {
      return null;
    }
    return value;
  }

  /// 0 以上の整数へ丸める。不正は null。
  static int? _nonNegativeInt(Object? raw) {
    final value = _asDouble(raw);
    if (value == null || value < 0 || !value.isFinite) {
      return null;
    }
    return value.round();
  }

  /// JSON 値を double へ写す。
  static double? _asDouble(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      return double.tryParse(raw.trim().replaceAll(',', ''));
    }
    return null;
  }

  /// ラベル付き断片から計測値を取る（JSON 失敗時のフォールバック）。
  static MeterReadingValues _parseLabeledText(String rawText) {
    final normalized = _normalize(rawText);
    if (normalized.isEmpty) {
      return const MeterReadingValues();
    }
    return MeterReadingValues(
      distanceKm: _firstNumberAfterLabels(
        normalized,
        const ['distance_km', 'distance', '走行距離', '距離'],
        unitHints: const ['km'],
      ),
      duration: _firstDuration(normalized),
      caloriesKcal: _firstNumberAfterLabels(
        normalized,
        const ['calories_kcal', 'calorie', 'calories', '消費カロリー', 'カロリー', '消費'],
        unitHints: const ['kcal', 'cal'],
      ),
      averageSpeedKmh: _firstNumberAfterLabels(
        normalized,
        const ['average_speed_kmh', 'average_speed', 'speed', '平均速度', '速度'],
        unitHints: const ['km/h', 'kmh'],
      ),
    );
  }

  /// 全角桁・空白を整え、比較用に小文字化する。
  static String _normalize(String raw) {
    final buffer = StringBuffer();
    for (final unit in raw.runes) {
      final ch = String.fromCharCode(unit);
      if (unit >= 0xff10 && unit <= 0xff19) {
        buffer.writeCharCode(0x30 + (unit - 0xff10));
        continue;
      }
      if (ch == '，') {
        buffer.write(',');
        continue;
      }
      if (ch == '：') {
        buffer.write(':');
        continue;
      }
      buffer.write(ch);
    }
    return buffer.toString().toLowerCase();
  }

  /// ラベル直後の最初の妥当な数値を返す。次ラベルを越えない。
  ///
  /// Example:
  /// ```dart
  /// _firstNumberAfterLabels('距離 12.3 km', ['距離'], unitHints: ['km']); // 12.3
  /// ```
  static double? _firstNumberAfterLabels(
    String text,
    List<String> labels, {
    required List<String> unitHints,
  }) {
    for (final label in labels) {
      final pattern = RegExp(
        '${RegExp.escape(label)}\\s*[=:]?\\s*',
        caseSensitive: false,
      );
      for (final match in pattern.allMatches(text)) {
        final segment = _segmentUntilNextLabel(text, match.end);
        final value = _parseFiniteNumber(segment);
        if (value == null || !_isPlausibleMetric(value)) {
          continue;
        }
        if (!_unitAllowed(segment, unitHints: unitHints)) {
          continue;
        }
        return value;
      }
    }
    return null;
  }

  /// [from] から次の項目ラベル直前までの部分文字列。
  ///
  /// Example:
  /// ```dart
  /// _segmentUntilNextLabel('12.3 km 時間 1:00:00', 0); // '12.3 km '
  /// ```
  static String _segmentUntilNextLabel(String text, int from) {
    if (from >= text.length) {
      return '';
    }
    var end = text.length;
    for (final label in _boundaryLabels) {
      final next = RegExp(
        '(?:^|([\\s、,，.。;；:：!！?？\\-—–]))${RegExp.escape(label)}(?=[\\s=:\\d]|\$)',
        caseSensitive: false,
      ).firstMatch(text.substring(from));
      if (next == null) {
        continue;
      }
      final prefixLength = next.group(1)?.length ?? 0;
      final absolute = from + next.start + prefixLength;
      if (absolute >= from && absolute < end) {
        end = absolute;
      }
    }
    final newline = text.indexOf('\n', from);
    if (newline != -1 && newline < end) {
      end = newline;
    }
    return text.substring(from, end);
  }

  /// 許可単位のみ受け入れる。単位無しは許可。未登録単位は拒否。
  ///
  /// Example:
  /// ```dart
  /// _unitAllowed('12.3 km', unitHints: ['km']); // true
  /// _unitAllowed('100 cm', unitHints: ['km']); // false
  /// ```
  static bool _unitAllowed(String segment, {required List<String> unitHints}) {
    final cleaned = segment.replaceAll(',', '').toLowerCase();
    final number = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(cleaned);
    if (number == null) {
      return false;
    }
    final after = cleaned.substring(number.end).trimLeft();
    final unitMatch = RegExp(r'^([a-z]+(?:/[a-z]+)?)').firstMatch(after);
    if (unitMatch == null) {
      return true;
    }
    final unit = unitMatch.group(1)!;
    for (final hint in unitHints) {
      if (unit == hint.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  /// 時間ラベル付きの Duration を最初の妥当な候補から取る。
  static Duration? _firstDuration(String text) {
    const labels = ['duration', 'time', '運動時間', '時間'];
    for (final label in labels) {
      final pattern = RegExp(
        '${RegExp.escape(label)}\\s*[=:]?\\s*',
        caseSensitive: false,
      );
      for (final match in pattern.allMatches(text)) {
        final segment = _segmentUntilNextLabel(text, match.end);
        final duration = MeterDurationParser.parse(segment);
        if (duration != null) {
          return duration;
        }
      }
    }
    return null;
  }

  /// ラベル後トークンから有限数値を取る。
  static double? _parseFiniteNumber(String token) {
    final cleaned = token.replaceAll(',', '');
    final match = RegExp(r'(-?\d+(?:\.\d+)?)').firstMatch(cleaned);
    if (match == null) {
      return null;
    }
    final value = double.tryParse(match.group(1)!);
    if (value == null || !value.isFinite) {
      return null;
    }
    return value;
  }

  /// 0 未満または 1e6 超は未取得。
  static bool _isPlausibleMetric(double value) =>
      value >= 0 && value <= 1000000;
}
