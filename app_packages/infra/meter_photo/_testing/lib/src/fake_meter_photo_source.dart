import 'package:infra_meter_photo/infra_meter_photo.dart';

/// テスト用の固定写真ソース。
///
/// キャンセルは戻り値 null、権限拒否はフラグで再現する。
///
/// Example:
/// ```dart
/// FakeMeterPhotoSource(cameraCapture: MeterPhotoCapture(bytes: Uint8List(0)));
/// ```
final class FakeMeterPhotoSource implements MeterPhotoSource {
  /// 返却値と権限拒否フラグを指定する。
  ///
  /// Example:
  /// ```dart
  /// FakeMeterPhotoSource(throwPermissionOnCamera: true);
  /// ```
  FakeMeterPhotoSource({
    this.cameraCapture,
    this.libraryCapture,
    this.throwPermissionOnCamera = false,
    this.throwPermissionOnLibrary = false,
  });

  /// [captureWithCamera] が返す値。null はキャンセル。
  MeterPhotoCapture? cameraCapture;

  /// [pickFromLibrary] が返す値。null はキャンセル。
  MeterPhotoCapture? libraryCapture;

  /// true のときカメラで権限拒否例外を投げる。
  bool throwPermissionOnCamera;

  /// true のときライブラリで権限拒否例外を投げる。
  bool throwPermissionOnLibrary;

  /// [captureWithCamera] が呼ばれた回数。
  int captureCallCount = 0;

  /// [pickFromLibrary] が呼ばれた回数。
  int pickCallCount = 0;

  /// [cameraCapture] を返すか権限拒否する。
  ///
  /// Example:
  /// ```dart
  /// await FakeMeterPhotoSource().captureWithCamera();
  /// ```
  @override
  Future<MeterPhotoCapture?> captureWithCamera() async {
    captureCallCount += 1;
    if (throwPermissionOnCamera) {
      throw const MeterPhotoPermissionDeniedException(
        MeterPhotoPermissionKind.camera,
      );
    }
    return cameraCapture;
  }

  /// [libraryCapture] を返すか権限拒否する。
  ///
  /// Example:
  /// ```dart
  /// await FakeMeterPhotoSource().pickFromLibrary();
  /// ```
  @override
  Future<MeterPhotoCapture?> pickFromLibrary() async {
    pickCallCount += 1;
    if (throwPermissionOnLibrary) {
      throw const MeterPhotoPermissionDeniedException(
        MeterPhotoPermissionKind.library,
      );
    }
    return libraryCapture;
  }
}
