import 'package:riverpod/riverpod.dart';

import 'app_runtime_info.dart';

/// 端末から [AppRuntimeInfo] を読む。
///
/// Example:
/// ```dart
/// AppRuntimeInfoReader.provider;
/// ```
abstract interface class AppRuntimeInfoReader {
  /// 未接続時は失敗する注入点。
  static final provider = Provider<AppRuntimeInfoReader>(
    (ref) => throw UnimplementedError('AppRuntimeInfoReader.provider'),
  );

  /// 必須項目が欠けるときは throw する。
  ///
  /// Example:
  /// ```dart
  /// await reader.read();
  /// ```
  Future<AppRuntimeInfo> read();
}
