import 'meter_vl_prepare_failure_kind.dart';

/// メーター VL モデル準備の失敗。
///
/// Example:
/// ```dart
/// throw const MeterVlPrepareException(
///   MeterVlPrepareFailureKind.wifiRequired,
/// );
/// ```
final class MeterVlPrepareException implements Exception {
  /// [kind] と任意の [message] を持つ失敗を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterVlPrepareException(
  ///   MeterVlPrepareFailureKind.network,
  /// );
  /// ```
  const MeterVlPrepareException(this.kind, {this.message});

  /// ダイアログ文言の切り替えに使う失敗種別。
  ///
  /// Example:
  /// ```dart
  /// exception.kind;
  /// ```
  final MeterVlPrepareFailureKind kind;

  /// 任意の補足（ログ向け。利用者向け文言ではない）。
  ///
  /// Example:
  /// ```dart
  /// exception.message;
  /// ```
  final String? message;

  /// [kind] と [message] を含む短い説明。
  ///
  /// Example:
  /// ```dart
  /// exception.toString();
  /// ```
  @override
  String toString() =>
      'MeterVlPrepareException($kind'
      '${message == null ? '' : ', $message'})';
}
