import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:infra_network_connectivity/infra_network_connectivity.dart';

/// [Connectivity] の結果のうち [ConnectivityResult.wifi] だけを true とみなす。
///
/// Example:
/// ```dart
/// ConnectivityPlusNetworkConnectivity();
/// ```
final class ConnectivityPlusNetworkConnectivity implements NetworkConnectivity {
  /// [connectivity] を省略すると既定の [Connectivity] を使う。
  ///
  /// Example:
  /// ```dart
  /// ConnectivityPlusNetworkConnectivity();
  /// ```
  ConnectivityPlusNetworkConnectivity({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  /// connectivity_plus への問い合わせ先。
  final Connectivity _connectivity;

  /// [ConnectivityResult.wifi] を含むときだけ true。
  ///
  /// Example:
  /// ```dart
  /// await ConnectivityPlusNetworkConnectivity().isWifi;
  /// ```
  @override
  Future<bool> get isWifi async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }
}
