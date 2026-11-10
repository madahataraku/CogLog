import 'package:riverpod/riverpod.dart';

import 'load_notification_settings_request.dart';
import 'load_notification_settings_result.dart';

/// 通知設定と許可状態を読む。
///
/// Example:
/// ```dart
/// usecase.execute(const LoadNotificationSettingsRequest());
/// ```
abstract interface class LoadNotificationSettingsUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<LoadNotificationSettingsUsecase>(
    (ref) =>
        throw UnimplementedError('LoadNotificationSettingsUsecase.provider'),
  );

  /// 設定と許可を返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(const LoadNotificationSettingsRequest());
  /// ```
  Future<LoadNotificationSettingsResult> execute(
    LoadNotificationSettingsRequest request,
  );
}
