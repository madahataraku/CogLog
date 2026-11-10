import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';

/// アプリ設定画面の読込状態と実行情報。
///
/// Example:
/// ```dart
/// AppSettingsScreenState.initial;
/// ```
final class AppSettingsScreenState {
  /// [loading] 中は [info] をまだ確定させない。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsScreenState(loading: true, info: null);
  /// ```
  const AppSettingsScreenState({required this.loading, this.info});

  /// 初期状態。
  static const initial = AppSettingsScreenState(loading: true);

  /// 実行情報の読込中なら true。
  final bool loading;

  /// 取得できたときのアプリ実行情報。
  final AppRuntimeInfo? info;
}
