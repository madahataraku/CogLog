import 'meter_photo_permission_kind.dart';

/// OS がカメラまたは写真ライブラリ権限を拒否した。
///
/// Example:
/// ```dart
/// throw const MeterPhotoPermissionDeniedException(MeterPhotoPermissionKind.camera);
/// ```
final class MeterPhotoPermissionDeniedException implements Exception {
  /// [kind] を保持する拒否例外を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterPhotoPermissionDeniedException(MeterPhotoPermissionKind.library);
  /// ```
  const MeterPhotoPermissionDeniedException(this.kind);

  /// 拒否された権限種別。
  final MeterPhotoPermissionKind kind;

  /// デバッグ用の短い説明。
  ///
  /// Example:
  /// ```dart
  /// const MeterPhotoPermissionDeniedException(MeterPhotoPermissionKind.camera).toString();
  /// ```
  @override
  String toString() => 'MeterPhotoPermissionDeniedException($kind)';
}
