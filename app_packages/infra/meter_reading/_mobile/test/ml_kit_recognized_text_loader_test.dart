import 'package:flutter_test/flutter_test.dart';
import 'package:infra_meter_reading_mobile/src/ml_kit_recognized_text_loader.dart';

void main() {
  test('日本語が成功したらラテンは呼ばない', () async {
    var latinCalls = 0;
    final value = await runJapaneseThenLatin(
      japanese: () async => 'ja',
      latin: () async {
        latinCalls += 1;
        return 'la';
      },
    );
    expect(value, 'ja');
    expect(latinCalls, 0);
  });

  test('日本語が失敗したらラテンへ落とす', () async {
    final value = await runJapaneseThenLatin(
      japanese: () async => throw StateError('japanese'),
      latin: () async => 'la',
    );
    expect(value, 'la');
  });

  test('両方失敗したら日本語側の例外を投げる', () async {
    await expectLater(
      () => runJapaneseThenLatin(
        japanese: () async => throw StateError('japanese'),
        latin: () async => throw StateError('latin'),
      ),
      throwsA(
        isA<StateError>().having((e) => e.message, 'message', 'japanese'),
      ),
    );
  });
}
