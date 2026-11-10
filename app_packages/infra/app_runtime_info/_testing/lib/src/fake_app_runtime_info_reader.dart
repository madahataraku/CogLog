import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';

/// 固定値または例外を返すテスト用 reader。
///
/// Example:
/// ```dart
/// FakeAppRuntimeInfoReader(
///   info: const AppRuntimeInfo(
///     versionName: '0.1.0',
///     buildNumber: '1',
///     osName: 'Android',
///   ),
/// );
/// ```
final class FakeAppRuntimeInfoReader implements AppRuntimeInfoReader {
  /// [info] か [error] のどちらかを使う。
  ///
  /// Example:
  /// ```dart
  /// FakeAppRuntimeInfoReader(error: StateError('x'));
  /// ```
  FakeAppRuntimeInfoReader({this.info, this.error});

  /// 成功時に返す値。
  final AppRuntimeInfo? info;

  /// 失敗時に投げる値。
  final Object? error;

  /// [error] があれば throwし、なければ [info] を返す。
  ///
  /// Example:
  /// ```dart
  /// await FakeAppRuntimeInfoReader(info: info).read();
  /// ```
  @override
  Future<AppRuntimeInfo> read() async {
    final err = error;
    if (err != null) {
      throw err;
    }
    return info!;
  }
}
