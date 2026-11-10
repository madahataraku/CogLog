import 'package:flutter/widgets.dart';
import 'package:infra_meter_photo/infra_meter_photo.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';

/// [MeterPhotoSource] を画面向け状態へ写す実装。
///
/// Example:
/// ```dart
/// ControlMeterInAppCameraUsecaseImpl(source: source);
/// ```
final class ControlMeterInAppCameraUsecaseImpl
    implements ControlMeterInAppCameraUsecase {
  /// [source] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// ControlMeterInAppCameraUsecaseImpl(source: source);
  /// ```
  const ControlMeterInAppCameraUsecaseImpl({required this.source});

  /// 写真・カメラ口。
  final MeterPhotoSource source;

  /// infra の状態を UI 状態へ写して流す。
  ///
  /// Example:
  /// ```dart
  /// usecase.watch();
  /// ```
  @override
  Stream<MeterInAppCameraUiStatus> watch() =>
      source.watchInAppCamera().map(_mapStatus);

  /// プレビュー開始を委譲する。
  ///
  /// Example:
  /// ```dart
  /// await usecase.start();
  /// ```
  @override
  Future<void> start() => source.startInAppCamera();

  /// プレビュー停止を委譲する。
  ///
  /// Example:
  /// ```dart
  /// await usecase.stop();
  /// ```
  @override
  Future<void> stop() => source.stopInAppCamera();

  /// プレビュー Widget を委譲する。
  ///
  /// Example:
  /// ```dart
  /// usecase.buildPreview();
  /// ```
  @override
  Widget buildPreview({Key? key}) => source.buildInAppPreview(key: key);

  /// infra の状態を画面向け状態へ写す。
  ///
  /// Example:
  /// ```dart
  /// usecase._mapStatus(const MeterInAppCameraIdle());
  /// ```
  MeterInAppCameraUiStatus _mapStatus(MeterInAppCameraStatus status) {
    return switch (status) {
      MeterInAppCameraIdle() => const MeterInAppCameraUiIdle(),
      MeterInAppCameraStarting() => const MeterInAppCameraUiStarting(),
      MeterInAppCameraReady(:final aspectRatio) => MeterInAppCameraUiReady(
        aspectRatio: aspectRatio,
      ),
      MeterInAppCameraPermissionDenied() =>
        const MeterInAppCameraUiPermissionDenied(),
      MeterInAppCameraFailed() => const MeterInAppCameraUiFailed(),
    };
  }
}
