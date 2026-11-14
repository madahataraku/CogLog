import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_top/src/view/map_gemma_meter_prepare_error.dart';

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(LocalizeStringDelegate.resetDelegateForTest);

  test('wifi / storage / network / generic を区別する', () {
    expect(
      mapGemmaMeterPrepareError(
        const GemmaMeterPrepareException(
          GemmaMeterPrepareFailureKind.wifiRequired,
        ),
      ),
      'Wi-Fiに接続してから再度お試しください。',
    );
    expect(
      mapGemmaMeterPrepareError(
        const GemmaMeterPrepareException(
          GemmaMeterPrepareFailureKind.insufficientStorage,
        ),
      ),
      '空き容量が足りません。容量を確保してから再度お試しください。',
    );
    expect(
      mapGemmaMeterPrepareError(
        const GemmaMeterPrepareException(GemmaMeterPrepareFailureKind.network),
      ),
      '通信に失敗しました。接続を確認してから再度お試しください。',
    );
    expect(
      mapGemmaMeterPrepareError(
        const GemmaMeterPrepareException(GemmaMeterPrepareFailureKind.generic),
      ),
      '準備に失敗しました。しばらくしてから再度お試しください。',
    );
  });

  test('未知の例外は共通文言', () {
    expect(
      mapGemmaMeterPrepareError(StateError('x')),
      '準備に失敗しました。しばらくしてから再度お試しください。',
    );
  });
}
