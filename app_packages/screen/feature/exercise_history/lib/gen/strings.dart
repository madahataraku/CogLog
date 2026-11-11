// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_internal_member, implementation_imports
import 'package:monolith_localization_runtime/src/localize_string_delegate.dart';

/// e.g.
/// class _Strings with L10nStringsMixin {}
/// @internal
/// final strings = _Strings();
mixin class L10nStringsMixin {
  const L10nStringsMixin();

  /// 同一日複数件のカレンダー上件数
  String screen_feature_exercise_history_count_badge({required String count}) =>
      LocalizeStringDelegate.get(
        'screen_feature_exercise_history_count_badge',
        arguments: [count],
      );

  /// 一覧の読込失敗
  String get screen_feature_exercise_history_error =>
      LocalizeStringDelegate.get('screen_feature_exercise_history_error');

  /// 月セレクタのラベル
  String screen_feature_exercise_history_month_label({
    required String year,
    required String month,
  }) => LocalizeStringDelegate.get(
    'screen_feature_exercise_history_month_label',
    arguments: [year, month],
  );

  /// 再試行ボタン
  String get screen_feature_exercise_history_retry =>
      LocalizeStringDelegate.get('screen_feature_exercise_history_retry');

  /// スタンプ日の VoiceOver 等
  String screen_feature_exercise_history_stamp_semantics({
    required String day,
    required String count,
  }) => LocalizeStringDelegate.get(
    'screen_feature_exercise_history_stamp_semantics',
    arguments: [day, count],
  );

  /// 画面タイトル
  String get screen_feature_exercise_history_title =>
      LocalizeStringDelegate.get('screen_feature_exercise_history_title');

  /// カレンダー曜日（金曜）
  String get screen_feature_exercise_history_weekday_fri =>
      LocalizeStringDelegate.get('screen_feature_exercise_history_weekday_fri');

  /// カレンダー曜日（月曜）
  String get screen_feature_exercise_history_weekday_mon =>
      LocalizeStringDelegate.get('screen_feature_exercise_history_weekday_mon');

  /// カレンダー曜日（土曜）
  String get screen_feature_exercise_history_weekday_sat =>
      LocalizeStringDelegate.get('screen_feature_exercise_history_weekday_sat');

  /// カレンダー曜日（日曜）
  String get screen_feature_exercise_history_weekday_sun =>
      LocalizeStringDelegate.get('screen_feature_exercise_history_weekday_sun');

  /// カレンダー曜日（木曜）
  String get screen_feature_exercise_history_weekday_thu =>
      LocalizeStringDelegate.get('screen_feature_exercise_history_weekday_thu');

  /// カレンダー曜日（火曜）
  String get screen_feature_exercise_history_weekday_tue =>
      LocalizeStringDelegate.get('screen_feature_exercise_history_weekday_tue');

  /// カレンダー曜日（水曜）
  String get screen_feature_exercise_history_weekday_wed =>
      LocalizeStringDelegate.get('screen_feature_exercise_history_weekday_wed');
}
