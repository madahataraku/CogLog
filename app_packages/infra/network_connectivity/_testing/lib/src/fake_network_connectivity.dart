import 'package:infra_network_connectivity/infra_network_connectivity.dart';

/// 固定の [isWifi] を返すテスト用実装。
///
/// Example:
/// ```dart
/// FakeNetworkConnectivity(isWifiValue: false);
/// ```
final class FakeNetworkConnectivity implements NetworkConnectivity {
  /// [isWifiValue] を返す実装を作る。
  ///
  /// Example:
  /// ```dart
  /// FakeNetworkConnectivity();
  /// ```
  FakeNetworkConnectivity({this.isWifiValue = true});

  /// [isWifi] が返す値。
  final bool isWifiValue;

  /// [isWifi] が呼ばれた回数。
  int isWifiCallCount = 0;

  /// [isWifiValue] を返し、呼び出し回数を増やす。
  ///
  /// Example:
  /// ```dart
  /// await FakeNetworkConnectivity().isWifi;
  /// ```
  @override
  Future<bool> get isWifi async {
    isWifiCallCount += 1;
    return isWifiValue;
  }
}
