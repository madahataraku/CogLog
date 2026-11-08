part of 'obtain_meter_photo_result.dart';

/// 取得成功。
final class ObtainMeterPhotoSuccess extends ObtainMeterPhotoResult {
  /// [bytes] と任意の [capturedAt] を持つ成功結果。
  ///
  /// Example:
  /// ```dart
  /// ObtainMeterPhotoSuccess(bytes: Uint8List(0));
  /// ```
  const ObtainMeterPhotoSuccess({required this.bytes, this.capturedAt});

  /// 画像バイト。
  final Uint8List bytes;

  /// 撮影日時。無ければ null。
  final DateTime? capturedAt;
}
