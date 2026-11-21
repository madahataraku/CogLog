import 'package:flutter_test/flutter_test.dart';
import 'package:infra_meter_photo/infra_meter_photo.dart';

void main() {
  final now = DateTime(2026, 11, 21, 12);

  test('境界内は採用する', () {
    expect(
      isAcceptableMeterPhotoCapturedAt(DateTime(2000, 1, 1), now: now),
      isTrue,
    );
    expect(
      isAcceptableMeterPhotoCapturedAt(
        now.add(const Duration(days: 1)),
        now: now,
      ),
      isTrue,
    );
  });

  test('2000年より前は拒否する', () {
    expect(
      isAcceptableMeterPhotoCapturedAt(
        DateTime(1999, 12, 31, 23, 59, 59),
        now: now,
      ),
      isFalse,
    );
  });

  test('now+1日より後は拒否する', () {
    expect(
      isAcceptableMeterPhotoCapturedAt(
        now.add(const Duration(days: 1, seconds: 1)),
        now: now,
      ),
      isFalse,
    );
  });
}
