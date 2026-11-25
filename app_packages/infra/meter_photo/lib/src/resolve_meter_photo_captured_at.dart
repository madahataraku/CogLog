import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'meter_photo_captured_at_guard.dart';

/// EXIF / OS 撮影・作成相当から採用する撮影日時を決める。
///
/// [bytes] は正規化前。優先は EXIF DateTimeOriginal → DateTimeDigitized →
/// DateTime。次に [assetCapturedOrCreatedAt]。
/// EXIF 日時フィールドが存在するが不正／異常な場合は、asset へ落とさず null
/// （未取得）とする。フィールド自体が無いときだけ asset を試す。
/// JPEG は画素デコードせず EXIF だけ読む。
///
/// Example:
/// ```dart
/// resolveMeterPhotoCapturedAt(
///   bytes: Uint8List(0),
///   now: DateTime.timestamp(),
/// );
/// ```
DateTime? resolveMeterPhotoCapturedAt({
  required Uint8List bytes,
  DateTime? assetCapturedOrCreatedAt,
  required DateTime now,
}) {
  final exifLookup = _lookupExifCapturedAt(bytes);
  if (exifLookup.hadField) {
    final fromExif = exifLookup.value;
    if (fromExif == null) {
      return null;
    }
    if (!isAcceptableMeterPhotoCapturedAt(fromExif, now: now)) {
      return null;
    }
    return fromExif;
  }

  final asset = assetCapturedOrCreatedAt;
  if (asset == null) {
    return null;
  }
  if (!isAcceptableMeterPhotoCapturedAt(asset, now: now)) {
    return null;
  }
  return asset;
}

/// EXIF 日時フィールドの有無と、解釈できたときの値。
final class _ExifCapturedAtLookup {
  const _ExifCapturedAtLookup._({required this.hadField, this.value});

  /// 日時フィールドが無かったとき。
  const _ExifCapturedAtLookup.missing() : this._(hadField: false);

  /// フィールドはあったが解釈不能なとき。
  const _ExifCapturedAtLookup.invalid() : this._(hadField: true);

  /// フィールドを解釈できたとき。
  const _ExifCapturedAtLookup.ok(DateTime value)
    : this._(hadField: true, value: value);

  /// EXIF の撮影日時相当フィールドが見つかったか。
  final bool hadField;

  /// 解釈できた撮影日時。不正なときは null。
  final DateTime? value;
}

/// [bytes] から EXIF 撮影日時フィールドを探す。
///
/// Example:
/// ```dart
/// _lookupExifCapturedAt(Uint8List(0));
/// ```
_ExifCapturedAtLookup _lookupExifCapturedAt(Uint8List bytes) {
  try {
    // 画素デコードせず JPEG APP1 の EXIF だけ読む（大きな写真の UI 負荷を避ける）。
    final exif = img.decodeJpgExif(bytes);
    if (exif == null || exif.isEmpty) {
      return const _ExifCapturedAtLookup.missing();
    }
    final raw =
        _exifAscii(exif.exifIfd, 0x9003) ??
        _exifAscii(exif.exifIfd, 0x9004) ??
        _exifAscii(exif.imageIfd, 0x0132);
    if (raw == null) {
      return const _ExifCapturedAtLookup.missing();
    }
    final parsed = _parseExifDateTime(raw);
    if (parsed == null) {
      return const _ExifCapturedAtLookup.invalid();
    }
    return _ExifCapturedAtLookup.ok(parsed);
  } on Object {
    return const _ExifCapturedAtLookup.missing();
  }
}

/// IFD [tag] の ASCII 値を trim して返す。空なら null。
///
/// Example:
/// ```dart
/// _exifAscii(img.IfdDirectory(), 0x9003);
/// ```
String? _exifAscii(img.IfdDirectory ifd, int tag) {
  final value = ifd[tag];
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

/// EXIF の `yyyy:MM:dd HH:mm:ss` を端末ローカル壁時計の [DateTime] にする。
///
/// 不正な暦日（例: 2 月 30 日）は [DateTime] の繰り上げを採用せず null にする。
///
/// Example:
/// ```dart
/// _parseExifDateTime('2024:05:18 12:33:21');
/// ```
DateTime? _parseExifDateTime(String raw) {
  final cleaned = raw.trim();
  final match = RegExp(
    r'^(\d{4}):(\d{2}):(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?',
  ).firstMatch(cleaned);
  if (match == null) {
    return null;
  }
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final hour = int.parse(match.group(4)!);
  final minute = int.parse(match.group(5)!);
  final second = int.parse(match.group(6) ?? '0');
  if (month < 1 ||
      month > 12 ||
      day < 1 ||
      day > 31 ||
      hour > 23 ||
      minute > 59 ||
      second > 59) {
    return null;
  }
  try {
    final parsed = DateTime(year, month, day, hour, minute, second);
    // DateTime は不正日を繰り上げるため、成分が一致しない場合は拒否する。
    if (parsed.year != year ||
        parsed.month != month ||
        parsed.day != day ||
        parsed.hour != hour ||
        parsed.minute != minute ||
        parsed.second != second) {
      return null;
    }
    return parsed;
  } on Object {
    return null;
  }
}
