import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// `package_info_plus` と `device_info_plus` から読む本番実装。
///
/// Example:
/// ```dart
/// const PackageDeviceAppRuntimeInfoReader();
/// ```
final class PackageDeviceAppRuntimeInfoReader implements AppRuntimeInfoReader {
  /// 本番 reader を作る。
  ///
  /// Example:
  /// ```dart
  /// const PackageDeviceAppRuntimeInfoReader();
  /// ```
  const PackageDeviceAppRuntimeInfoReader();

  /// 必須項目が空なら [StateError]、非モバイルなら [UnsupportedError]。
  ///
  /// Example:
  /// ```dart
  /// await const PackageDeviceAppRuntimeInfoReader().read();
  /// ```
  @override
  Future<AppRuntimeInfo> read() async {
    final package = await PackageInfo.fromPlatform();
    if (package.version.isEmpty || package.buildNumber.isEmpty) {
      throw StateError('package version missing');
    }
    final String osName;
    final String? osVersion;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await DeviceInfoPlugin().androidInfo;
        osName = 'Android';
        osVersion = info.version.release.isEmpty ? null : info.version.release;
      case TargetPlatform.iOS:
        final info = await DeviceInfoPlugin().iosInfo;
        osName = 'iOS';
        osVersion = info.systemVersion.isEmpty ? null : info.systemVersion;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        throw UnsupportedError('unsupported platform');
    }
    return AppRuntimeInfo(
      versionName: package.version,
      buildNumber: package.buildNumber,
      osName: osName,
      osVersion: osVersion,
    );
  }
}
