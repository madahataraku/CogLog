/// ネイティブ層が返す Gemma 可用性。
///
/// Example:
/// ```dart
/// const GemmaMeterNativeAvailability(
///   status: 'ready',
///   reason: 'ready',
///   message: 'ok',
/// );
/// ```
final class GemmaMeterNativeAvailability {
  /// [status] / [reason] / [message] を保持する。
  ///
  /// Example:
  /// ```dart
  /// const GemmaMeterNativeAvailability(
  ///   status: 'ready',
  ///   reason: 'ready',
  ///   message: 'ok',
  /// );
  /// ```
  const GemmaMeterNativeAvailability({
    required this.status,
    required this.reason,
    required this.message,
  });

  /// MethodChannel の Map から復元する。
  ///
  /// 欠落キーは unavailable / unknown / 既定文に落とす。
  ///
  /// Example:
  /// ```dart
  /// GemmaMeterNativeAvailability.fromMap(const {
  ///   'status': 'ready',
  ///   'reason': 'ready',
  ///   'message': 'ok',
  /// });
  /// ```
  factory GemmaMeterNativeAvailability.fromMap(Map<String, dynamic> map) {
    return GemmaMeterNativeAvailability(
      status: map['status'] as String? ?? 'unavailable',
      reason: map['reason'] as String? ?? 'unknown',
      message: map['message'] as String? ?? 'Unknown availability state.',
    );
  }

  /// `ready` / `modelNotDownloaded` / `unavailable`。
  final String status;

  /// 短い理由名（例: `ready` / `platformUnsupported`）。
  final String reason;

  /// UI・診断向け説明（測定値は含めない）。
  final String message;

  /// [status] が `ready` のとき true。
  bool get isReady => status == 'ready';
}
