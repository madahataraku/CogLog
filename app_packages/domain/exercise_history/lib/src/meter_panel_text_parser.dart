import 'meter_reading_values.dart';

/// OCR／LLM の生テキストからメーター計測値を取り出す。
///
/// Example:
/// ```dart
/// MeterPanelTextParser.parse('DISTANCE_KM=12.3\nDURATION=1:00:00');
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
    final normalized = _normalize(rawText);
    if (normalized.isEmpty) {
      return const MeterReadingValues();
    }
    return MeterReadingValues(
      distanceKm: _firstNumberAfterLabels(
        normalized,
        const ['distance_km', 'distance', '走行距離', '距離'],
        unitHints: const ['km'],
        rejectUnits: const ['mi', 'mile', 'miles', 'm'],
      ),
      duration: _firstDuration(normalized),
      caloriesKcal: _firstNumberAfterLabels(
        normalized,
        const ['calories_kcal', 'calorie', 'calories', '消費カロリー', 'カロリー', '消費'],
        unitHints: const ['kcal', 'cal'],
        rejectUnits: const ['kj'],
      ),
      averageSpeedKmh: _firstNumberAfterLabels(
        normalized,
        const ['average_speed_kmh', 'average_speed', 'speed', '平均速度', '速度'],
        unitHints: const ['km/h', 'kmh'],
        rejectUnits: const ['mph', 'mi/h'],
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
  static double? _firstNumberAfterLabels(
    String text,
    List<String> labels, {
    required List<String> unitHints,
    List<String> rejectUnits = const [],
  }) {
    for (final label in labels) {
      final pattern = RegExp(
        '${RegExp.escape(label)}\\s*[=:]?\\s*',
        caseSensitive: false,
      );
      for (final match in pattern.allMatches(text)) {
        final segment = _segmentUntilNextLabel(text, match.end);
        if (!_unitAllowed(
          segment,
          unitHints: unitHints,
          rejectUnits: rejectUnits,
        )) {
          continue;
        }
        final value = _parseFiniteNumber(segment);
        if (value != null && _isPlausibleMetric(value)) {
          return value;
        }
      }
    }
    return null;
  }

  /// [from] から次の項目ラベル直前までの部分文字列。
  static String _segmentUntilNextLabel(String text, int from) {
    if (from >= text.length) {
      return '';
    }
    var end = text.length;
    for (final label in _boundaryLabels) {
      final next = RegExp(
        '(?:^|\\s)${RegExp.escape(label)}(?:\\s|[=:]|\$)',
        caseSensitive: false,
      ).firstMatch(text.substring(from));
      if (next == null) {
        continue;
      }
      final absolute = from + next.start;
      if (absolute > from && absolute < end) {
        end = absolute;
      }
    }
    final newline = text.indexOf('\n', from);
    if (newline != -1 && newline < end) {
      end = newline;
    }
    return text.substring(from, end);
  }

  /// 対応単位のみ許可。拒否単位があれば未取得。単位無しは許可。
  static bool _unitAllowed(
    String segment, {
    required List<String> unitHints,
    required List<String> rejectUnits,
  }) {
    final cleaned = segment.replaceAll(',', '').toLowerCase();
    for (final reject in rejectUnits) {
      if (_containsUnitToken(cleaned, reject)) {
        return false;
      }
    }
    const knownUnits = [
      'km/h',
      'kmh',
      'km',
      'kcal',
      'cal',
      'miles',
      'mile',
      'mph',
      'mi/h',
      'mi',
      'kj',
      'm',
    ];
    var sawUnit = false;
    for (final unit in knownUnits) {
      if (_containsUnitToken(cleaned, unit)) {
        sawUnit = true;
        break;
      }
    }
    if (!sawUnit) {
      return true;
    }
    for (final hint in unitHints) {
      if (_containsUnitToken(cleaned, hint.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  /// [unit] が数値に付く／単独トークンとして含まれるか。
  static bool _containsUnitToken(String text, String unit) {
    final escaped = RegExp.escape(unit);
    return RegExp(
      '(?:^|[^a-z/])$escaped(?:[^a-z/]|\$)',
      caseSensitive: false,
    ).hasMatch(text);
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
        final duration = _parseDurationToken(segment);
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

  /// `H:MM:SS` / `M:SS` / `HhMmSs` / 日本語表記を Duration にする。
  static Duration? _parseDurationToken(String token) {
    final jp = RegExp(r'(?:(\d+)\s*時間)?\s*(?:(\d+)\s*分)?\s*(?:(\d+)\s*秒)?')
        .firstMatch(token);
    if (jp != null &&
        (jp.group(1) != null || jp.group(2) != null || jp.group(3) != null)) {
      final hours = int.tryParse(jp.group(1) ?? '') ?? 0;
      final minutes = int.tryParse(jp.group(2) ?? '') ?? 0;
      final seconds = int.tryParse(jp.group(3) ?? '') ?? 0;
      if (hours < 0 || minutes < 0 || seconds < 0) {
        return null;
      }
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }

    final hms = RegExp(r'(\d+)h\s*(\d+)m\s*(\d+)s').firstMatch(token);
    if (hms != null) {
      return Duration(
        hours: int.parse(hms.group(1)!),
        minutes: int.parse(hms.group(2)!),
        seconds: int.parse(hms.group(3)!),
      );
    }

    final colon = RegExp(r'(\d+):(\d{1,2})(?::(\d{1,2}))?').firstMatch(token);
    if (colon != null) {
      final first = int.parse(colon.group(1)!);
      final second = int.parse(colon.group(2)!);
      final third = colon.group(3);
      if (third != null) {
        return Duration(
          hours: first,
          minutes: second,
          seconds: int.parse(third),
        );
      }
      return Duration(minutes: first, seconds: second);
    }
    return null;
  }
}
