import 'package:data_repository_health_write_guidance_impl/data_repository_health_write_guidance_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('未保存は false', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesHealthWriteGuidanceRepository(
      preferences,
    );
    expect(await repository.isSeen(), isFalse);
  });

  test('markSeen のあと isSeen は true', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesHealthWriteGuidanceRepository(
      preferences,
    );
    await repository.markSeen();
    expect(await repository.isSeen(), isTrue);
  });
}
