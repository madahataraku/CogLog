import 'package:data_repository_health_write_guidance_testing/data_repository_health_write_guidance_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_health_write_guidance_impl/usecase_health_write_guidance_impl.dart';

void main() {
  test('未提示なら shouldShow は true', () async {
    final guidance = MemoryHealthWriteGuidanceRepository();
    final usecase = HealthWriteGuidanceUsecaseImpl(guidance: guidance);
    expect(await usecase.shouldShow(), isTrue);
  });

  test('markSeen のあと shouldShow は false', () async {
    final guidance = MemoryHealthWriteGuidanceRepository();
    final usecase = HealthWriteGuidanceUsecaseImpl(guidance: guidance);
    await usecase.markSeen();
    expect(await usecase.shouldShow(), isFalse);
  });
}
