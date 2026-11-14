import 'gemma_meter_prepare_failure_kind.dart';

/// Gemma モデル準備の失敗。
///
/// Example:
/// ```dart
/// throw const GemmaMeterPrepareException(
///   GemmaMeterPrepareFailureKind.wifiRequired,
/// );
/// ```
final class GemmaMeterPrepareException implements Exception {
  /// [kind] と任意の [message] を持つ失敗を作る。
  ///
  /// Example:
  /// ```dart
  /// const GemmaMeterPrepareException(
  ///   GemmaMeterPrepareFailureKind.network,
  /// );
  /// ```
  const GemmaMeterPrepareException(this.kind, {this.message});

  /// ダイアログ文言の切り替えに使う失敗種別。
  ///
  /// Example:
  /// ```dart
  /// exception.kind;
  /// ```
  final GemmaMeterPrepareFailureKind kind;

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
      'GemmaMeterPrepareException($kind'
      '${message == null ? '' : ', $message'})';
}
