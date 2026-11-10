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
  String get screen_feature_meter_capture_back => '戻る';

  @override
  String get screen_feature_meter_capture_calories => '消費カロリー (kcal)';

  @override
  String get screen_feature_meter_capture_capture_photo => '撮影する';

  @override
  String get screen_feature_meter_capture_distance => '走行距離 (km)';

  @override
  String get screen_feature_meter_capture_duration_hours => '時間';

  @override
  String get screen_feature_meter_capture_duration_minutes => '分';

  @override
  String get screen_feature_meter_capture_duration_seconds => '秒';

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
  String get screen_feature_meter_capture_save => '登録';

  @override
  String get screen_feature_meter_capture_save_failed => '保存に失敗しました';

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
  String get screen_feature_top_this_month => '今月';

  @override
  String get screen_feature_top_this_week => '今週';

  @override
  String get screen_feature_top_today => '本日';

  @override
  String get screen_feature_top_unset_prompt => '目標設定で一日あたりの目標を設定しましょう';

  @override
  String get screen_feature_trends_chart_placeholder => 'グラフは準備中です';

  @override
  String get screen_feature_trends_group_body => '身体';

  @override
  String get screen_feature_trends_group_exercise => '運動';

  @override
  String get screen_feature_trends_period_days182 => '過去半年';

  @override
  String get screen_feature_trends_period_days30 => '過去30日';

  @override
  String get screen_feature_trends_period_days365 => '過去1年';

  @override
  String get screen_feature_trends_period_days90 => '過去3カ月';

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
