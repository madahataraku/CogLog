import 'dart:typed_data';

/// 取得した写真バイトと任意の撮影日時。
///
/// Example:
/// ```dart
/// MeterPhotoCapture(bytes: Uint8List(0));
/// ```
final class MeterPhotoCapture {
  /// [bytes] と任意の [capturedAt] を持つ。
  ///
  /// Example:
  /// ```dart
  /// MeterPhotoCapture(bytes: Uint8List(0));
  /// ```
  const MeterPhotoCapture({required this.bytes, this.capturedAt});

  /// 画像バイト。
  final Uint8List bytes;

  /// 撮影日時。無ければ null。
  final DateTime? capturedAt;
}
