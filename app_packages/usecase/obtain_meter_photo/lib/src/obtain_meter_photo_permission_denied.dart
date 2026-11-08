part of 'obtain_meter_photo_result.dart';

/// 権限拒否。
final class ObtainMeterPhotoPermissionDenied extends ObtainMeterPhotoResult {
  /// [kind] を保持する拒否結果。
  ///
  /// Example:
  /// ```dart
  /// const ObtainMeterPhotoPermissionDenied(MeterPhotoPermissionKind.camera);
  /// ```
  const ObtainMeterPhotoPermissionDenied(this.kind);

  /// 拒否された権限種別。
  final MeterPhotoPermissionKind kind;
}
