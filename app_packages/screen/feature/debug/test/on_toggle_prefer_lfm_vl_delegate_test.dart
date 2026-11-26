import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:screen_feature_debug/src/viewmodel/delegate/on_toggle_prefer_lfm_vl_delegate.dart';
import 'package:screen_feature_debug/src/viewmodel/state/debug_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:test/test.dart';

void main() {
  test('オンにするとセッションと State が true', () async {
    final preference = MeterReadingEngineSessionPreference();
    final state = MutableStateStream(DebugScreenState.initial);
    await OnTogglePreferLfmVlDelegate(
      state: state,
      sessionPreference: preference,
    ).execute(true);
    expect(preference.preferLfmVlOverOsLlm, isTrue);
    expect(state.state.preferLfmVlOverOsLlm, isTrue);
  });

  test('オフに戻すとセッションと State が false', () async {
    final preference = MeterReadingEngineSessionPreference()
      ..preferLfmVlOverOsLlm = true;
    final state = MutableStateStream(
      DebugScreenState.initial.copyWith(preferLfmVlOverOsLlm: true),
    );
    await OnTogglePreferLfmVlDelegate(
      state: state,
      sessionPreference: preference,
    ).execute(false);
    expect(preference.preferLfmVlOverOsLlm, isFalse);
    expect(state.state.preferLfmVlOverOsLlm, isFalse);
  });
}
