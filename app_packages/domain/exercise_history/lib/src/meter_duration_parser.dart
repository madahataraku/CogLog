/// メーター表示の時間トークンを [Duration] へ写す。
///
/// Example:
/// ```dart
/// MeterDurationParser.parse('0:30:00');
/// ```
abstract final class MeterDurationParser {
  /// [token] から読めたときだけ [Duration] を返す。
  ///
  /// 対応形式は `H:MM:SS` / `M:SS` / `HhMmSs` / 日本語の時分秒。
  ///
  /// Example:
  /// ```dart
  /// MeterDurationParser.parse('1:00:00'); // 1時間
  /// ```
  static Duration? parse(String token) {
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

    return parseColonOnly(token);
  }

  /// コロン形式（`H:MM:SS` / `M:SS`）だけを認める。
  ///
  /// 空間 OCR のアンカー無し時間採用に使う。
  ///
  /// Example:
  /// ```dart
  /// MeterDurationParser.parseColonOnly('0:45:00');
  /// ```
  static Duration? parseColonOnly(String token) {
    final colon = RegExp(r'^\s*(\d+)[:：](\d{1,2})(?:[:：](\d{1,2}))?\s*$')
        .firstMatch(token);
    if (colon == null) {
      return null;
    }
    final first = int.parse(colon.group(1)!);
    final second = int.parse(colon.group(2)!);
    final third = colon.group(3);
    if (third != null) {
      final seconds = int.parse(third);
      if (second > 59 || seconds > 59) {
        return null;
      }
      return Duration(hours: first, minutes: second, seconds: seconds);
    }
    if (second > 59) {
      return null;
    }
    return Duration(minutes: first, seconds: second);
  }
}
