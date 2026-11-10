import '../entity/oss_licenses_screen_entity.dart';
import '../state/oss_licenses_screen_state.dart';

/// State を表示用 Entity へ写す。
///
/// Example:
/// ```dart
/// const OssLicensesStateToEntityDelegate();
/// ```
final class OssLicensesStateToEntityDelegate {
  /// 変換委譲を作る。
  ///
  /// Example:
  /// ```dart
  /// const OssLicensesStateToEntityDelegate();
  /// ```
  const OssLicensesStateToEntityDelegate();

  /// [state] を Entity にする。
  ///
  /// Example:
  /// ```dart
  /// const OssLicensesStateToEntityDelegate().execute(
  ///   OssLicensesScreenState.initial,
  /// );
  /// ```
  OssLicensesScreenEntity execute(OssLicensesScreenState state) {
    final names = [for (final entry in state.entries) entry.name];
    return OssLicensesScreenEntity(packageNames: names, isEmpty: names.isEmpty);
  }
}
