import 'package:flutter_test/flutter_test.dart';
import 'package:infra_meter_photo/infra_meter_photo.dart';
import 'package:infra_meter_photo_testing/infra_meter_photo_testing.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';
import 'package:usecase_control_meter_in_app_camera_impl/usecase_control_meter_in_app_camera_impl.dart';

void main() {
  test('start 後の ready が UiReady に写る', () async {
    final source = FakeMeterPhotoSource(
      startBehavior: const MeterInAppCameraReady(aspectRatio: 1.2),
    );
    final usecase = ControlMeterInAppCameraUsecaseImpl(source: source);
    final future = usecase.watch().firstWhere((s) => s is MeterInAppCameraUiReady);
    await usecase.start();
    final status = await future;
    expect(status, isA<MeterInAppCameraUiReady>());
    expect((status as MeterInAppCameraUiReady).aspectRatio, 1.2);
  });

  test('permissionDenied が UiPermissionDenied に写る', () async {
    final source = FakeMeterPhotoSource(
      startBehavior: const MeterInAppCameraPermissionDenied(),
    );
    final usecase = ControlMeterInAppCameraUsecaseImpl(source: source);
    final future = usecase.watch().firstWhere(
      (s) => s is MeterInAppCameraUiPermissionDenied,
    );
    await usecase.start();
    expect(await future, isA<MeterInAppCameraUiPermissionDenied>());
  });
}
