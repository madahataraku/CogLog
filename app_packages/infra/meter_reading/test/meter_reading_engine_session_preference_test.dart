import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:test/test.dart';

void main() {
  test('初期は preferLfmVlOverOsLlm が false', () {
    final preference = MeterReadingEngineSessionPreference();
    expect(preference.preferLfmVlOverOsLlm, isFalse);
  });

  test('preferLfmVlOverOsLlm を書き換えられる', () {
    final preference = MeterReadingEngineSessionPreference()
      ..preferLfmVlOverOsLlm = true;
    expect(preference.preferLfmVlOverOsLlm, isTrue);
    preference.preferLfmVlOverOsLlm = false;
    expect(preference.preferLfmVlOverOsLlm, isFalse);
  });
}
