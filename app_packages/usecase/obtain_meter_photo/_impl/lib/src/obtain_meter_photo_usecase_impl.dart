import 'package:infra_meter_photo/infra_meter_photo.dart' as infra;
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';

/// [infra.MeterPhotoSource] の呼び出しを成功・キャンセル・権限拒否へ分ける。
///
/// Example:
/// ```dart
/// ObtainMeterPhotoUsecaseImpl(source: source).execute(
///   const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.camera),
/// );
/// ```
final class ObtainMeterPhotoUsecaseImpl implements ObtainMeterPhotoUsecase {
  /// [source] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// ObtainMeterPhotoUsecaseImpl(source: source);
  /// ```
  const ObtainMeterPhotoUsecaseImpl({required this.source});

  /// カメラ／ライブラリ取得口。
  final infra.MeterPhotoSource source;

  /// [request] の取得元を呼び、結果へ変換する。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.library),
  /// );
  /// ```
  @override
  Future<ObtainMeterPhotoResult> execute(
    ObtainMeterPhotoRequest request,
  ) async {
    try {
      final capture = switch (request.source) {
        ObtainMeterPhotoSource.camera => await source.captureWithCamera(),
        ObtainMeterPhotoSource.library => await source.pickFromLibrary(),
      };
      if (capture == null) {
        return const ObtainMeterPhotoCancelled();
      }
      return ObtainMeterPhotoSuccess(
        bytes: capture.bytes,
        capturedAt: capture.capturedAt,
      );
    } on infra.MeterPhotoPermissionDeniedException catch (error) {
      return ObtainMeterPhotoPermissionDenied(_mapKind(error.kind));
    }
  }

  /// infra の権限種別を usecase の種別へ写す。
  ///
  /// Example:
  /// ```dart
  /// _mapKind(infra.MeterPhotoPermissionKind.camera);
  /// ```
  static MeterPhotoPermissionKind _mapKind(
    infra.MeterPhotoPermissionKind kind,
  ) {
    return switch (kind) {
      infra.MeterPhotoPermissionKind.camera => MeterPhotoPermissionKind.camera,
      infra.MeterPhotoPermissionKind.library =>
        MeterPhotoPermissionKind.library,
    };
  }
}
