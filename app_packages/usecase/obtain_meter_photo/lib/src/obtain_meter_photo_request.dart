/// 写真取得の入力元。
enum ObtainMeterPhotoSource {
  /// カメラ撮影。
  camera,

  /// 写真ライブラリ。
  library,
}

/// カメラまたはライブラリからの取得依頼。
///
/// Example:
/// ```dart
/// const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.camera);
/// ```
final class ObtainMeterPhotoRequest {
  /// [source] を指定して依頼を作る。
  ///
  /// Example:
  /// ```dart
  /// const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.library);
  /// ```
  const ObtainMeterPhotoRequest({required this.source});

  /// 取得元。
  final ObtainMeterPhotoSource source;
}
