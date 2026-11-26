import 'package:data_repository_health_write_guidance_testing/data_repository_health_write_guidance_testing.dart';
import 'package:infra_health_workout_testing/infra_health_workout_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_health_write_guidance_impl/usecase_health_write_guidance_impl.dart';

void main() {
  test('未提示かつ未連携なら shouldShow は true', () async {
    final usecase = HealthWriteGuidanceUsecaseImpl(
      guidance: MemoryHealthWriteGuidanceRepository(),
      health: FakeHealthWorkoutWriter(writePermissionGranted: false),
    );
    expect(await usecase.shouldShow(), isTrue);
  });

  test('markSeen のあと shouldShow は false', () async {
    final usecase = HealthWriteGuidanceUsecaseImpl(
      guidance: MemoryHealthWriteGuidanceRepository(),
      health: FakeHealthWorkoutWriter(writePermissionGranted: false),
    );
    await usecase.markSeen();
    expect(await usecase.shouldShow(), isFalse);
  });

  test('書き込み権限が既にあれば未提示でも shouldShow は false', () async {
    final usecase = HealthWriteGuidanceUsecaseImpl(
      guidance: MemoryHealthWriteGuidanceRepository(),
      health: FakeHealthWorkoutWriter(writePermissionGranted: true),
    );
    expect(await usecase.shouldShow(), isFalse);
  });
}
