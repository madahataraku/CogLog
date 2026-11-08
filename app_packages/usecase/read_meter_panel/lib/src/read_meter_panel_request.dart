import 'dart:typed_data';

/// 読み取るメーターパネル写真。
///
/// Example:
/// ```dart
/// ReadMeterPanelRequest(photoBytes: Uint8List(0));
/// ```
final class ReadMeterPanelRequest {
  /// [photoBytes] を読む依頼を作る。
  ///
  /// Example:
  /// ```dart
  /// ReadMeterPanelRequest(photoBytes: Uint8List(0));
  /// ```
  const ReadMeterPanelRequest({required this.photoBytes});

  /// 画像バイト。
  final Uint8List photoBytes;
}
