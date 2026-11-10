import '../entity/oss_license_detail_screen_entity.dart';
import '../state/oss_license_detail_screen_state.dart';

/// State を表示用 Entity へ写す。
///
/// Example:
/// ```dart
/// const OssLicenseDetailStateToEntityDelegate();
/// ```
final class OssLicenseDetailStateToEntityDelegate {
  /// 変換委譲を作る。
  ///
  /// Example:
  /// ```dart
  /// const OssLicenseDetailStateToEntityDelegate();
  /// ```
  const OssLicenseDetailStateToEntityDelegate();

  /// [state] を Entity にする。
  ///
  /// Example:
  /// ```dart
  /// const OssLicenseDetailStateToEntityDelegate().execute(
  ///   OssLicenseDetailScreenState.initial(packageName: 'riverpod'),
  /// );
  /// ```
  OssLicenseDetailScreenEntity execute(OssLicenseDetailScreenState state) {
    final text = state.licenseText;
    if (text == null || text.isEmpty) {
      return const OssLicenseDetailScreenEntity(licenseText: '', isEmpty: true);
    }
    return OssLicenseDetailScreenEntity(licenseText: text, isEmpty: false);
  }
}
