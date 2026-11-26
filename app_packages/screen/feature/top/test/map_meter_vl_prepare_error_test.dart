import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_top/src/view/map_meter_vl_prepare_error.dart';

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(LocalizeStringDelegate.resetDelegateForTest);

  test('wifi / storage / network / generic を区別する', () {
    expect(
      mapMeterVlPrepareError(
        const MeterVlPrepareException(MeterVlPrepareFailureKind.wifiRequired),
      ),
      'Wi-Fiに接続してから再度お試しください。',
    );
    expect(
      mapMeterVlPrepareError(
        const MeterVlPrepareException(
          MeterVlPrepareFailureKind.insufficientStorage,
        ),
      ),
      '空き容量が足りません。容量を確保してから再度お試しください。',
    );
    expect(
      mapMeterVlPrepareError(
        const MeterVlPrepareException(MeterVlPrepareFailureKind.network),
      ),
      '通信に失敗しました。接続を確認してから再度お試しください。',
    );
    expect(
      mapMeterVlPrepareError(
        const MeterVlPrepareException(MeterVlPrepareFailureKind.generic),
      ),
      '準備に失敗しました。しばらくしてから再度お試しください。',
    );
  });

  test('未知の例外は共通文言', () {
    expect(
      mapMeterVlPrepareError(StateError('x')),
      '準備に失敗しました。しばらくしてから再度お試しください。',
    );
  });
}
