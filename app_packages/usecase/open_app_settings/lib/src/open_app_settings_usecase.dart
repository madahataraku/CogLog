import 'package:riverpod/riverpod.dart';

/// OS のアプリ設定画面を開く。
///
/// Example:
/// ```dart
/// usecase.execute();
/// ```
abstract interface class OpenAppSettingsUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<OpenAppSettingsUsecase>(
    (ref) => throw UnimplementedError('OpenAppSettingsUsecase.provider'),
  );

  /// 設定アプリを開く。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute();
  /// ```
  Future<void> execute();
}
