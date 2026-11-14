import 'package:riverpod/riverpod.dart';

/// Wi-Fi 接続の有無を返す。
///
/// Example:
/// ```dart
/// await connectivity.isWifi;
/// ```
abstract interface class NetworkConnectivity {
  /// Wi-Fi 接続のときだけ true（cellular / ethernet / none は false）。
  ///
  /// Example:
  /// ```dart
  /// await connectivity.isWifi;
  /// ```
  Future<bool> get isWifi;
}

/// ネットワーク接続の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// networkConnectivityProvider;
/// ```
final networkConnectivityProvider = Provider<NetworkConnectivity>(
  (ref) => throw UnimplementedError('networkConnectivityProvider'),
);
