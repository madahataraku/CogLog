import 'meter_duration_parser.dart';
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
