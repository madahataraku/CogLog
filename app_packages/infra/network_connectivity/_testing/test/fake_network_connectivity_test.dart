import 'package:infra_network_connectivity_testing/infra_network_connectivity_testing.dart';
import 'package:test/test.dart';

void main() {
  test('既定の isWifi は true', () async {
    final connectivity = FakeNetworkConnectivity();
    expect(await connectivity.isWifi, isTrue);
    expect(connectivity.isWifiCallCount, 1);
  });

  test('isWifiValue false のとき false', () async {
    final connectivity = FakeNetworkConnectivity(isWifiValue: false);
    expect(await connectivity.isWifi, isFalse);
    expect(connectivity.isWifiCallCount, 1);
  });
}
