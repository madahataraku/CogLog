import 'package:infra_health_workout_mobile/src/workout_write_units.dart';
import 'package:test/test.dart';

void main() {
  test('distanceKmToMeters は四捨五入したメートル', () {
    expect(distanceKmToMeters(12.3), 12300);
    expect(distanceKmToMeters(0.0014), 1);
  });

  test('caloriesKcalToInt は四捨五入した整数', () {
    expect(caloriesKcalToInt(300.4), 300);
    expect(caloriesKcalToInt(300.5), 301);
  });

  test('isValidWorkoutUuid は null・空・null文字列を弾く', () {
    expect(isValidWorkoutUuid(null), isFalse);
    expect(isValidWorkoutUuid(''), isFalse);
    expect(isValidWorkoutUuid('null'), isFalse);
    expect(isValidWorkoutUuid('abc'), isTrue);
  });

  test('allWritePermissionsGranted は全 true のみ', () {
    expect(allWritePermissionsGranted({}), isFalse);
    expect(allWritePermissionsGranted({'a': true, 'b': true}), isTrue);
    expect(allWritePermissionsGranted({'a': true, 'b': false}), isFalse);
    expect(allWritePermissionsGranted({'a': true, 'b': null}), isFalse);
  });
}
