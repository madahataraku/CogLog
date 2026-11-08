import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infra_meter_photo/infra_meter_photo.dart';

/// [ImagePicker] でカメラ／ライブラリから写真を取る。
///
/// 撮影日時メタは常に null（EXIF 抽出は後続）。キャンセルは null。
/// 権限拒否は [MeterPhotoPermissionDeniedException]。
///
/// Example:
/// ```dart
/// ImagePickerMeterPhotoSource();
/// ```
final class ImagePickerMeterPhotoSource implements MeterPhotoSource {
  /// [picker] を差し替え可能にする。省略時は新規 [ImagePicker]。
  ///
  /// Example:
  /// ```dart
  /// ImagePickerMeterPhotoSource();
  /// ```
  ImagePickerMeterPhotoSource({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// カメラで撮影する。
  ///
  /// Example:
  /// ```dart
  /// await ImagePickerMeterPhotoSource().captureWithCamera();
  /// ```
  @override
  Future<MeterPhotoCapture?> captureWithCamera() =>
      _pick(source: ImageSource.camera, kind: MeterPhotoPermissionKind.camera);

  /// ライブラリから選ぶ。
  ///
  /// Example:
  /// ```dart
  /// await ImagePickerMeterPhotoSource().pickFromLibrary();
  /// ```
  @override
  Future<MeterPhotoCapture?> pickFromLibrary() => _pick(
    source: ImageSource.gallery,
    kind: MeterPhotoPermissionKind.library,
  );

  /// [source] から 1 枚取り、権限拒否を [kind] の例外へ写す。
  ///
  /// Example:
  /// ```dart
  /// await ImagePickerMeterPhotoSource()._pick(
  ///   source: ImageSource.camera,
  ///   kind: MeterPhotoPermissionKind.camera,
  /// );
  /// ```
  Future<MeterPhotoCapture?> _pick({
    required ImageSource source,
    required MeterPhotoPermissionKind kind,
  }) async {
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) {
        return null;
      }
      final bytes = await file.readAsBytes();
      return MeterPhotoCapture(bytes: bytes);
    } on PlatformException catch (error) {
      if (_isPermissionDenied(error)) {
        throw MeterPhotoPermissionDeniedException(kind);
      }
      rethrow;
    }
  }

  /// [error] が権限拒否コードか。
  ///
  /// Example:
  /// ```dart
  /// ImagePickerMeterPhotoSource()._isPermissionDenied(
  ///   PlatformException(code: 'camera_access_denied'),
  /// );
  /// ```
  bool _isPermissionDenied(PlatformException error) {
    final code = error.code.toLowerCase();
    return code.contains('access_denied') ||
        code.contains('permission') ||
        code == 'camera_access_denied' ||
        code == 'photo_access_denied';
  }
}
