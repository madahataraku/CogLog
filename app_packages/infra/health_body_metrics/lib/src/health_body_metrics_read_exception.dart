/// 身体指標の読取に失敗したときに投げる。
///
/// Usecase はこれを catch して再試行フラグへ写す。空リストへ黙って落とさない。
///
/// Example:
/// ```dart
/// throw const HealthBodyMetricsReadException('timeout');
/// ```
final class HealthBodyMetricsReadException implements Exception {
  /// 任意の [message] を持つ例外を作る。
  ///
  /// Example:
  /// ```dart
  /// const HealthBodyMetricsReadException();
  /// ```
  const HealthBodyMetricsReadException([this.message]);

  /// 失敗理由の説明。無くてもよい。
  final String? message;

  @override
  String toString() => message == null
      ? 'HealthBodyMetricsReadException'
      : 'HealthBodyMetricsReadException: $message';
}
