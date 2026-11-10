import 'package:riverpod/riverpod.dart';

import 'save_notification_settings_request.dart';
import 'save_notification_settings_result.dart';

/// 通知設定を保存し、リマインドを同期する。
///
/// Example:
/// ```dart
/// usecase.execute(const SaveNotificationSettingsRequest(enabled: true));
/// ```
abstract interface class SaveNotificationSettingsUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<SaveNotificationSettingsUsecase>(
    (ref) =>
        throw UnimplementedError('SaveNotificationSettingsUsecase.provider'),
  );

  /// ON なら許可を求め、設定を書いて同期する。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(const SaveNotificationSettingsRequest(enabled: true));
  /// ```
  Future<SaveNotificationSettingsResult> execute(
    SaveNotificationSettingsRequest request,
  );
}
