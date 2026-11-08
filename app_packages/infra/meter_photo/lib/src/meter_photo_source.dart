import 'package:riverpod/riverpod.dart';

import 'meter_photo_capture.dart';

/// カメラ／ライブラリからメーターパネル写真を取る。
///
/// Example:
/// ```dart
/// await source.captureWithCamera();
/// ```
abstract interface class MeterPhotoSource {
  /// カメラ撮影。キャンセルは null。権限拒否は例外。
  ///
  /// Example:
  /// ```dart
  /// await source.captureWithCamera();
  /// ```
  Future<MeterPhotoCapture?> captureWithCamera();

  /// ライブラリ選択。キャンセルは null。権限拒否は例外。
  ///
  /// Example:
  /// ```dart
  /// await source.pickFromLibrary();
  /// ```
  Future<MeterPhotoCapture?> pickFromLibrary();
}

/// メーター写真取得の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// meterPhotoSourceProvider;
/// ```
final meterPhotoSourceProvider = Provider<MeterPhotoSource>(
  (ref) => throw UnimplementedError('meterPhotoSourceProvider'),
);
