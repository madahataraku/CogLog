/// ネイティブ層が返す可用性。
///
/// Example:
/// ```dart
/// const OnDeviceLlmNativeAvailability(
///   status: 'available',
///   reason: 'ready',
///   message: 'ok',
/// );
/// ```
final class OnDeviceLlmNativeAvailability {
  /// [status] / [reason] / [message] を保持する。
  ///
  /// Example:
  /// ```dart
  /// const OnDeviceLlmNativeAvailability(
  ///   status: 'available',
  ///   reason: 'ready',
  ///   message: 'ok',
  /// );
  /// ```
  const OnDeviceLlmNativeAvailability({
    required this.status,
    required this.reason,
    required this.message,
  });

  /// MethodChannel の Map から復元する。
  ///
  /// Example:
  /// ```dart
  /// OnDeviceLlmNativeAvailability.fromMap(const {
  ///   'status': 'available',
  ///   'reason': 'ready',
  ///   'message': 'ok',
  /// });
  /// ```
  factory OnDeviceLlmNativeAvailability.fromMap(Map<String, dynamic> map) {
    return OnDeviceLlmNativeAvailability(
      status: map['status'] as String? ?? 'unavailable',
      reason: map['reason'] as String? ?? 'unknown',
      message: map['message'] as String? ?? 'Unknown availability state.',
    );
  }

  /// `available` / `downloadable` / `downloading` / `unavailable` など。
  final String status;

  /// `ready` / `modelNotReady` など。
  final String reason;

  /// UI 向け説明。
  final String message;

  /// 直ちに生成できるとき true。
  bool get isReady => status == 'available';
}
