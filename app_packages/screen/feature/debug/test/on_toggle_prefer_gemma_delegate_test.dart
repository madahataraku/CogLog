import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:screen_feature_debug/src/viewmodel/delegate/on_toggle_prefer_gemma_delegate.dart';
import 'package:screen_feature_debug/src/viewmodel/state/debug_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:test/test.dart';

void main() {
  test('オンにするとセッションと State が true', () async {
    final preference = MeterReadingEngineSessionPreference();
    final state = MutableStateStream(DebugScreenState.initial);
    await OnTogglePreferGemmaDelegate(
      state: state,
      sessionPreference: preference,
    ).execute(true);
    expect(preference.preferGemmaOverOsLlm, isTrue);
    expect(state.state.preferGemmaOverOsLlm, isTrue);
  });

  test('オフに戻すとセッションと State が false', () async {
    final preference = MeterReadingEngineSessionPreference()
      ..preferGemmaOverOsLlm = true;
    final state = MutableStateStream(
      const DebugScreenState(
        running: false,
        result: null,
        gemmaResult: null,
        logs: [],
        preferGemmaOverOsLlm: true,
      ),
    );
    await OnTogglePreferGemmaDelegate(
      state: state,
      sessionPreference: preference,
    ).execute(false);
    expect(preference.preferGemmaOverOsLlm, isFalse);
    expect(state.state.preferGemmaOverOsLlm, isFalse);
  });
}
