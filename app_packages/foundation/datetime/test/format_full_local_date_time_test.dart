import 'package:foundation_datetime/foundation_datetime.dart';
import 'package:test/test.dart';

/// [formatFullLocalDateTime] の ja/en 形式を検証する。
///
/// Example:
/// ```dart
/// main();
/// ```
void main() {
  // ローカル時刻として解釈される同一瞬間（タイムゾーン依存を避ける）。
  final sample = DateTime(2026, 5, 18, 12, 33, 21);

  test('ja の受け入れ例', () {
    expect(
      formatFullLocalDateTime(sample, languageCode: 'ja'),
      '2026年05月18日 12:33:21',
    );
  });

  test('en の受け入れ例', () {
    expect(
      formatFullLocalDateTime(sample, languageCode: 'en'),
      'May 18, 2026, 12:33:21',
    );
  });

  test('0:00:00 をゼロ埋めする', () {
    final midnight = DateTime(2026, 5, 18);
    expect(
      formatFullLocalDateTime(midnight, languageCode: 'ja'),
      '2026年05月18日 00:00:00',
    );
    expect(
      formatFullLocalDateTime(midnight, languageCode: 'en'),
      'May 18, 2026, 00:00:00',
    );
  });

  test('月日1桁は ja でゼロ埋め、en の日はゼロ埋めしない', () {
    final singleDigits = DateTime(2026, 1, 5, 9, 8, 7);
    expect(
      formatFullLocalDateTime(singleDigits, languageCode: 'ja'),
      '2026年01月05日 09:08:07',
    );
    expect(
      formatFullLocalDateTime(singleDigits, languageCode: 'en'),
      'Jan 5, 2026, 09:08:07',
    );
  });

  test('ja 以外は en 形式にする', () {
    expect(
      formatFullLocalDateTime(sample, languageCode: 'fr'),
      'May 18, 2026, 12:33:21',
    );
  });
}
