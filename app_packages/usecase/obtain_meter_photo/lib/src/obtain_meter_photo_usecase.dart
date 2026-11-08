import 'package:riverpod/riverpod.dart';

import 'obtain_meter_photo_request.dart';
import 'obtain_meter_photo_result.dart';

/// カメラまたは写真ライブラリからメーターパネル写真を取得する。
///
/// Example:
/// ```dart
/// usecase.execute(
///   const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.camera),
/// );
/// ```
abstract interface class ObtainMeterPhotoUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<ObtainMeterPhotoUsecase>(
    (ref) => throw UnimplementedError('ObtainMeterPhotoUsecase.provider'),
  );

  /// [request] の取得元から写真を取る。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.library),
  /// );
  /// ```
  Future<ObtainMeterPhotoResult> execute(ObtainMeterPhotoRequest request);
}
