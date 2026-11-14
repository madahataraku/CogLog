import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:test/test.dart';

void main() {
  test('初期は preferGemmaOverOsLlm が false', () {
    final preference = MeterReadingEngineSessionPreference();
    expect(preference.preferGemmaOverOsLlm, isFalse);
  });

  test('preferGemmaOverOsLlm を書き換えられる', () {
    final preference = MeterReadingEngineSessionPreference()
      ..preferGemmaOverOsLlm = true;
    expect(preference.preferGemmaOverOsLlm, isTrue);
    preference.preferGemmaOverOsLlm = false;
    expect(preference.preferGemmaOverOsLlm, isFalse);
  });
}
