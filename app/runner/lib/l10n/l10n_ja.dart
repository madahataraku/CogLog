// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String app_count(String count) {
    return '回数 $count';
  }

  @override
  String get app_increase => '増やす';

  @override
  String get foundation_resources_app_name => 'CogLog';

  @override
  String get screen_feature_app_settings_back_semantics => '戻る';

  @override
  String get screen_feature_app_settings_debug_item => 'デバッグ';

  @override
  String get screen_feature_app_settings_title => 'アプリ設定';

  @override
  String get screen_feature_debug_availability_error_label =>
      'availability error';

  @override
  String get screen_feature_debug_back_semantics => '戻る';

  @override
  String get screen_feature_debug_backend_label => 'backend';

  @override
  String get screen_feature_debug_can_generate_label => 'can generate';

  @override
  String get screen_feature_debug_clear_logs => 'ログを消去';

  @override
  String get screen_feature_debug_empty_logs => 'ログはまだありません';

  @override
  String get screen_feature_debug_generate_error_label => 'generate error';

  @override
  String get screen_feature_debug_message_label => 'message';

  @override
  String get screen_feature_debug_no => 'いいえ';

  @override
  String get screen_feature_debug_platform_notes_label => 'platform notes';

  @override
  String get screen_feature_debug_prepare_error_label => 'prepare error';

  @override
  String get screen_feature_debug_probe_skipped_label => 'probe skipped';

  @override
  String get screen_feature_debug_readiness_label => 'readiness';

  @override
  String get screen_feature_debug_reason_label => 'reason';

  @override
  String get screen_feature_debug_run_diagnose => '再診断';

  @override
  String get screen_feature_debug_running => '診断中…';

  @override
  String get screen_feature_debug_sample_output_label => 'sample output';

  @override
  String get screen_feature_debug_section_availability => '端末上 LLM';

  @override
  String get screen_feature_debug_section_logs => 'アプリログ';

  @override
  String get screen_feature_debug_section_probe => '生成プローブ';

  @override
  String get screen_feature_debug_status_label => 'status';

  @override
  String get screen_feature_debug_title => 'デバッグ';

  @override
  String get screen_feature_debug_yes => 'はい';

  @override
  String get screen_feature_exercise_history_calories => '消費カロリー';

  @override
  String get screen_feature_exercise_history_calories_unit => 'kcal';

  @override
  String get screen_feature_exercise_history_created_at => '作成開始日時';

  @override
  String get screen_feature_exercise_history_detail_average_speed => '平均速度';

  @override
  String get screen_feature_exercise_history_detail_average_speed_unit =>
      'km/h';

  @override
  String get screen_feature_exercise_history_detail_back => '戻る';

  @override
  String get screen_feature_exercise_history_detail_calories => '消費カロリー';

  @override
  String get screen_feature_exercise_history_detail_calories_unit => 'kcal';

  @override
  String get screen_feature_exercise_history_detail_captured_at => '撮影日時';

  @override
  String get screen_feature_exercise_history_detail_created_at => '作成開始日時';

  @override
  String get screen_feature_exercise_history_detail_distance => '走行距離';

  @override
  String get screen_feature_exercise_history_detail_distance_unit => 'km';

  @override
  String get screen_feature_exercise_history_detail_duration => '運動時間';

  @override
  String get screen_feature_exercise_history_detail_edited => '（編集済み）';

  @override
  String get screen_feature_exercise_history_detail_error => '詳細を読み込めませんでした';

  @override
  String get screen_feature_exercise_history_detail_missing => 'この運動履歴はありません';

  @override
  String get screen_feature_exercise_history_detail_photo => 'メーターパネル写真';

  @override
  String get screen_feature_exercise_history_detail_photo_error => '写真を表示できません';

  @override
  String get screen_feature_exercise_history_detail_recorded_at => '記録日時';

  @override
  String get screen_feature_exercise_history_detail_retry => '再試行';

  @override
  String get screen_feature_exercise_history_detail_saved_at => '保存日時';

  @override
  String get screen_feature_exercise_history_detail_title => '運動履歴詳細';

  @override
  String get screen_feature_exercise_history_distance => '走行距離';

  @override
  String get screen_feature_exercise_history_distance_unit => 'km';

  @override
  String get screen_feature_exercise_history_duration => '運動時間';

  @override
  String get screen_feature_exercise_history_empty =>
      'この月の運動履歴がありません。メーター記録から、メーターパネルの撮影または手入力で運動履歴を作成してください。';

  @override
  String get screen_feature_exercise_history_error => '運動履歴を読み込めませんでした';

  @override
  String get screen_feature_exercise_history_load_more_error => '続きを読み込めませんでした';

  @override
  String screen_feature_exercise_history_month_label(
    String year,
    String month,
  ) {
    return '$year年$month月';
  }

  @override
  String get screen_feature_exercise_history_retry => '再試行';

  @override
  String get screen_feature_exercise_history_title => '運動履歴';

  @override
  String get screen_feature_goal_settings_auto_update_description =>
      '連続して目標を達成すると、レベルに応じて目標を上方修正します';

  @override
  String get screen_feature_goal_settings_auto_update_enabled => '目標の自動更新';

  @override
  String get screen_feature_goal_settings_auto_update_level => '自動更新レベル';

  @override
  String get screen_feature_goal_settings_auto_update_level_challenging =>
      '挑戦的';

  @override
  String get screen_feature_goal_settings_auto_update_level_normal => 'ふつう';

  @override
  String get screen_feature_goal_settings_auto_update_level_slow => 'ゆっくり';

  @override
  String get screen_feature_goal_settings_calories_label => '消費カロリー';

  @override
  String get screen_feature_goal_settings_calories_unit => 'kcal';

  @override
  String get screen_feature_goal_settings_distance_label => '走行距離';

  @override
  String get screen_feature_goal_settings_distance_unit => 'km';

  @override
  String get screen_feature_goal_settings_duration_label => '運動時間';

  @override
  String get screen_feature_goal_settings_hours_label => '時間';

  @override
  String get screen_feature_goal_settings_minutes_label => '分';

  @override
  String get screen_feature_goal_settings_save => '保存';

  @override
  String get screen_feature_goal_settings_save_failed => '目標を保存できませんでした';

  @override
  String get screen_feature_goal_settings_save_invalid_input => '入力内容を確認してください';

  @override
  String get screen_feature_goal_settings_save_success => '目標を保存しました';

  @override
  String get screen_feature_goal_settings_seconds_label => '秒';

  @override
  String get screen_feature_goal_settings_title => '目標設定';

  @override
  String get screen_feature_goal_settings_unset_hint => '未設定の欄は空のまま保存できます';

  @override
  String get screen_feature_main_nav_exercise_history => '運動履歴';

  @override
  String get screen_feature_main_nav_goal_settings => '目標設定';

  @override
  String get screen_feature_main_nav_home => 'ホーム';

  @override
  String get screen_feature_main_nav_meter_capture => 'メーター記録';

  @override
  String get screen_feature_main_nav_trends => '推移';

  @override
  String get screen_feature_meter_capture_average_speed => '平均速度 (km/h)';

  @override
  String get screen_feature_meter_capture_calories => '消費カロリー (kcal)';

  @override
  String get screen_feature_meter_capture_camera_preview_failed =>
      'カメラを開始できませんでした。ライブラリから選ぶか、しばらくしてから撮り直してください。';

  @override
  String get screen_feature_meter_capture_capture_failed =>
      '撮影に失敗しました。もう一度シャッターを押すか、ライブラリから選んでください。';

  @override
  String get screen_feature_meter_capture_distance => '走行距離 (km)';

  @override
  String get screen_feature_meter_capture_duration_hours => '時間';

  @override
  String get screen_feature_meter_capture_duration_minutes => '分';

  @override
  String get screen_feature_meter_capture_duration_seconds => '秒';

  @override
  String get screen_feature_meter_capture_goal_auto_updated => '目標が自動更新されました';

  @override
  String get screen_feature_meter_capture_open_settings => '設定を開く';

  @override
  String get screen_feature_meter_capture_permission_camera => 'カメラの許可が必要です';

  @override
  String get screen_feature_meter_capture_permission_library =>
      '写真へのアクセス許可が必要です';

  @override
  String get screen_feature_meter_capture_pick_library => 'ライブラリから選ぶ';

  @override
  String get screen_feature_meter_capture_reading => '読み取り中…';

  @override
  String get screen_feature_meter_capture_recorded_at => '記録日時';

  @override
  String get screen_feature_meter_capture_retake => '撮り直す';

  @override
  String get screen_feature_meter_capture_save => '登録';

  @override
  String get screen_feature_meter_capture_save_failed => '保存に失敗しました';

  @override
  String get screen_feature_meter_capture_shutter => 'シャッター';

  @override
  String get screen_feature_meter_capture_title => 'メーター記録';

  @override
  String get screen_feature_top_achievement_title => '目標達成率';

  @override
  String get screen_feature_top_actual_label => '実績';

  @override
  String get screen_feature_top_advice_no_exercise =>
      '今日はまだ運動の記録がありません。無理のないペースで始めましょう。';

  @override
  String get screen_feature_top_advice_template_1 =>
      '水分をこまめに取って、無理のないペースを保ちましょう。';

  @override
  String get screen_feature_top_advice_template_2 =>
      'よく動けました。回復のためにも休息を大切にしましょう。';

  @override
  String get screen_feature_top_advice_template_3 => '小さな積み重ねが続きます。今日も自分のペースで。';

  @override
  String get screen_feature_top_advisor_semantics => 'アドバイザー';

  @override
  String get screen_feature_top_calories => '消費カロリー';

  @override
  String get screen_feature_top_calories_unit => 'kcal';

  @override
  String get screen_feature_top_distance => '走行距離';

  @override
  String get screen_feature_top_distance_unit => 'km';

  @override
  String get screen_feature_top_duration => '運動時間';

  @override
  String get screen_feature_top_goal_label => '目標';

  @override
  String get screen_feature_top_settings_semantics => 'アプリ設定';

  @override
  String get screen_feature_top_this_month => '今月';

  @override
  String get screen_feature_top_this_week => '今週';

  @override
  String get screen_feature_top_today => '本日';

  @override
  String get screen_feature_top_unset_prompt => '目標設定で一日あたりの目標を設定しましょう';

  @override
  String get screen_feature_trends_chart_placeholder => '読み込み中';

  @override
  String get screen_feature_trends_group_body => '身体';

  @override
  String get screen_feature_trends_group_exercise => '運動';

  @override
  String get screen_feature_trends_group_label => 'グループ';

  @override
  String get screen_feature_trends_metric_body_fat => '体脂肪率';

  @override
  String get screen_feature_trends_metric_body_kg => '体重と除脂肪体重';

  @override
  String get screen_feature_trends_metric_body_lean_mass => '除脂肪体重';

  @override
  String get screen_feature_trends_metric_body_weight => '体重';

  @override
  String get screen_feature_trends_metric_calories => '消費カロリー';

  @override
  String get screen_feature_trends_metric_distance => '走行距離';

  @override
  String get screen_feature_trends_metric_duration => '運動時間';

  @override
  String get screen_feature_trends_metric_label => '指標';

  @override
  String get screen_feature_trends_open_os_settings => '設定を開く';

  @override
  String get screen_feature_trends_period_days182 => '過去半年';

  @override
  String get screen_feature_trends_period_days30 => '過去30日';

  @override
  String get screen_feature_trends_period_days365 => '過去1年';

  @override
  String get screen_feature_trends_period_days90 => '過去3カ月';

  @override
  String get screen_feature_trends_period_label => '期間';

  @override
  String get screen_feature_trends_request_health_history => 'ヘルスの履歴データを許可';

  @override
  String get screen_feature_trends_request_health_permission => 'ヘルスケアを許可';

  @override
  String get screen_feature_trends_retry_load => '再試行';

  @override
  String get screen_feature_trends_title => '推移';

  @override
  String get view_model_download_guidance_body =>
      'ワンポイントアドバイス等に使うモデルが端末にありません。準備を開始できます。準備中もアプリは利用できます。';

  @override
  String get view_model_download_guidance_dismiss => '閉じる';

  @override
  String get view_model_download_guidance_prepare => 'モデルを準備';

  @override
  String get view_model_download_guidance_prepare_failed =>
      '準備に失敗しました。しばらくしてから再度お試しください。';

  @override
  String get view_model_download_guidance_title => '端末上のAIモデルの準備';
}
