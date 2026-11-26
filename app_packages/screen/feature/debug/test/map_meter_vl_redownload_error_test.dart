import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_debug/src/viewmodel/delegate/debug_state_to_entity_delegate.dart';

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(LocalizeStringDelegate.resetDelegateForTest);

  test('4 kind + null を区別する', () {
    expect(
      mapMeterVlRedownloadError(MeterVlPrepareFailureKind.wifiRequired),
      'Wi-Fiに接続してから再度お試しください。',
    );
    expect(
      mapMeterVlRedownloadError(
        MeterVlPrepareFailureKind.insufficientStorage,
      ),
      '空き容量が足りません。容量を確保してから再度お試しください。',
    );
    expect(
      mapMeterVlRedownloadError(MeterVlPrepareFailureKind.network),
      '通信に失敗しました。接続を確認してから再度お試しください。',
    );
    expect(
      mapMeterVlRedownloadError(MeterVlPrepareFailureKind.generic),
      'LFM VL の再ダウンロードに失敗しました。しばらくしてから再度お試しください。',
    );
    expect(
      mapMeterVlRedownloadError(null),
      'LFM VL の再ダウンロードに失敗しました。しばらくしてから再度お試しください。',
    );
  });
}