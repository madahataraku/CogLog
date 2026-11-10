// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String app_count(String count) {
    return 'Count $count';
  }

  @override
  String get app_increase => 'Increase';

  @override
  String get foundation_resources_app_name => 'CogLog';

  @override
  String get screen_feature_app_settings_back_semantics => 'Back';

  @override
  String get screen_feature_app_settings_debug_item => 'Debug';

  @override
  String get screen_feature_app_settings_title => 'App settings';

  @override
  String get screen_feature_debug_availability_error_label =>
      'availability error';

  @override
  String get screen_feature_debug_back_semantics => 'Back';

  @override
  String get screen_feature_debug_backend_label => 'backend';

  @override
  String get screen_feature_debug_can_generate_label => 'can generate';

  @override
  String get screen_feature_debug_clear_logs => 'Clear logs';

  @override
  String get screen_feature_debug_empty_logs => 'No logs yet';

  @override
  String get screen_feature_debug_generate_error_label => 'generate error';

  @override
  String get screen_feature_debug_message_label => 'message';

  @override
  String get screen_feature_debug_no => 'No';

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
  String get screen_feature_debug_run_diagnose => 'Re-diagnose';

  @override
  String get screen_feature_debug_running => 'Diagnosing…';

  @override
  String get screen_feature_debug_sample_output_label => 'sample output';

  @override
  String get screen_feature_debug_section_availability => 'On-device LLM';

  @override
  String get screen_feature_debug_section_logs => 'App logs';

  @override
  String get screen_feature_debug_section_probe => 'Generation probe';

  @override
  String get screen_feature_debug_status_label => 'status';

  @override
  String get screen_feature_debug_title => 'Debug';

  @override
  String get screen_feature_debug_yes => 'Yes';

  @override
  String get screen_feature_exercise_history_calories => 'Calories';

  @override
  String get screen_feature_exercise_history_calories_unit => 'kcal';

  @override
  String get screen_feature_exercise_history_created_at => 'Created at';

  @override
  String get screen_feature_exercise_history_detail_average_speed =>
      'Average speed';

  @override
  String get screen_feature_exercise_history_detail_average_speed_unit =>
      'km/h';

  @override
  String get screen_feature_exercise_history_detail_back => 'Back';

  @override
  String get screen_feature_exercise_history_detail_calories => 'Calories';

  @override
  String get screen_feature_exercise_history_detail_calories_unit => 'kcal';

  @override
  String get screen_feature_exercise_history_detail_captured_at =>
      'Captured at';

  @override
  String get screen_feature_exercise_history_detail_created_at => 'Created at';

  @override
  String get screen_feature_exercise_history_detail_distance => 'Distance';

  @override
  String get screen_feature_exercise_history_detail_distance_unit => 'km';

  @override
  String get screen_feature_exercise_history_detail_duration => 'Duration';

  @override
  String get screen_feature_exercise_history_detail_edited => '(edited)';

  @override
  String get screen_feature_exercise_history_detail_error =>
      'Could not load detail';

  @override
  String get screen_feature_exercise_history_detail_missing =>
      'This exercise history was not found';

  @override
  String get screen_feature_exercise_history_detail_photo =>
      'Meter panel photo';

  @override
  String get screen_feature_exercise_history_detail_photo_error =>
      'Could not show photo';

  @override
  String get screen_feature_exercise_history_detail_recorded_at =>
      'Recorded at';

  @override
  String get screen_feature_exercise_history_detail_retry => 'Retry';

  @override
  String get screen_feature_exercise_history_detail_saved_at => 'Saved at';

  @override
  String get screen_feature_exercise_history_detail_title =>
      'Exercise history detail';

  @override
  String get screen_feature_exercise_history_distance => 'Distance';

  @override
  String get screen_feature_exercise_history_distance_unit => 'km';

  @override
  String get screen_feature_exercise_history_duration => 'Duration';

  @override
  String get screen_feature_exercise_history_empty =>
      'No exercise history this month. Create one from Meter record by photographing the meter panel or entering values manually.';

  @override
  String get screen_feature_exercise_history_error =>
      'Could not load exercise history';

  @override
  String get screen_feature_exercise_history_load_more_error =>
      'Could not load more';

  @override
  String screen_feature_exercise_history_month_label(
    String year,
    String month,
  ) {
    return '$year/$month';
  }

  @override
  String get screen_feature_exercise_history_retry => 'Retry';

  @override
  String get screen_feature_exercise_history_title => 'Exercise history';

  @override
  String get screen_feature_goal_settings_calories_label => 'Calories';

  @override
  String get screen_feature_goal_settings_calories_unit => 'kcal';

  @override
  String get screen_feature_goal_settings_distance_label => 'Distance';

  @override
  String get screen_feature_goal_settings_distance_unit => 'km';

  @override
  String get screen_feature_goal_settings_duration_label => 'Exercise time';

  @override
  String get screen_feature_goal_settings_hours_label => 'Hours';

  @override
  String get screen_feature_goal_settings_minutes_label => 'Minutes';

  @override
  String get screen_feature_goal_settings_save => 'Save';

  @override
  String get screen_feature_goal_settings_save_failed => 'Could not save goals';

  @override
  String get screen_feature_goal_settings_save_invalid_input =>
      'Check your input values';

  @override
  String get screen_feature_goal_settings_save_success => 'Goals saved';

  @override
  String get screen_feature_goal_settings_seconds_label => 'Seconds';

  @override
  String get screen_feature_goal_settings_title => 'Goals';

  @override
  String get screen_feature_goal_settings_unset_hint =>
      'Leave fields empty to keep them unset';

  @override
  String get screen_feature_main_nav_exercise_history => 'Exercise history';

  @override
  String get screen_feature_main_nav_goal_settings => 'Goals';

  @override
  String get screen_feature_main_nav_home => 'Home';

  @override
  String get screen_feature_main_nav_meter_capture => 'Meter record';

  @override
  String get screen_feature_main_nav_trends => 'Trends';

  @override
  String get screen_feature_meter_capture_average_speed =>
      'Average speed (km/h)';

  @override
  String get screen_feature_meter_capture_calories => 'Calories (kcal)';

  @override
  String get screen_feature_meter_capture_camera_preview_failed =>
      'Couldn\'t start the camera. Pick from your library or try again.';

  @override
  String get screen_feature_meter_capture_capture_failed =>
      'Couldn\'t take the photo. Try the shutter again or pick from your library.';

  @override
  String get screen_feature_meter_capture_distance => 'Distance (km)';

  @override
  String get screen_feature_meter_capture_duration_hours => 'Hours';

  @override
  String get screen_feature_meter_capture_duration_minutes => 'Minutes';

  @override
  String get screen_feature_meter_capture_duration_seconds => 'Seconds';

  @override
  String get screen_feature_meter_capture_open_settings => 'Open settings';

  @override
  String get screen_feature_meter_capture_permission_camera =>
      'Camera permission is required';

  @override
  String get screen_feature_meter_capture_permission_library =>
      'Photo library permission is required';

  @override
  String get screen_feature_meter_capture_pick_library => 'Choose from library';

  @override
  String get screen_feature_meter_capture_reading => 'Reading…';

  @override
  String get screen_feature_meter_capture_recorded_at => 'Recorded at';

  @override
  String get screen_feature_meter_capture_retake => 'Retake';

  @override
  String get screen_feature_meter_capture_save => 'Save';

  @override
  String get screen_feature_meter_capture_save_failed => 'Failed to save';

  @override
  String get screen_feature_meter_capture_shutter => 'Shutter';

  @override
  String get screen_feature_meter_capture_title => 'Meter record';

  @override
  String get screen_feature_top_achievement_title => 'Goal progress';

  @override
  String get screen_feature_top_actual_label => 'Actual';

  @override
  String get screen_feature_top_advice_no_exercise =>
      'No exercise logged today. Start at a comfortable pace.';

  @override
  String get screen_feature_top_advice_template_1 =>
      'Stay hydrated and keep a comfortable pace.';

  @override
  String get screen_feature_top_advice_template_2 =>
      'Nice work. Rest matters as much as the workout.';

  @override
  String get screen_feature_top_advice_template_3 =>
      'Small steps add up. Keep your own pace today.';

  @override
  String get screen_feature_top_advisor_semantics => 'Advisor';

  @override
  String get screen_feature_top_calories => 'Calories';

  @override
  String get screen_feature_top_calories_unit => 'kcal';

  @override
  String get screen_feature_top_distance => 'Distance';

  @override
  String get screen_feature_top_distance_unit => 'km';

  @override
  String get screen_feature_top_duration => 'Exercise time';

  @override
  String get screen_feature_top_goal_label => 'Goal';

  @override
  String get screen_feature_top_settings_semantics => 'App settings';

  @override
  String get screen_feature_top_this_month => 'This month';

  @override
  String get screen_feature_top_this_week => 'This week';

  @override
  String get screen_feature_top_today => 'Today';

  @override
  String get screen_feature_top_unset_prompt => 'Set a daily goal in Goals';

  @override
  String get screen_feature_trends_chart_placeholder => 'Chart coming soon';

  @override
  String get screen_feature_trends_group_body => 'Body';

  @override
  String get screen_feature_trends_group_exercise => 'Exercise';

  @override
  String get screen_feature_trends_group_label => 'Group';

  @override
  String get screen_feature_trends_period_days182 => 'Last 6 months';

  @override
  String get screen_feature_trends_period_days30 => 'Last 30 days';

  @override
  String get screen_feature_trends_period_days365 => 'Last 1 year';

  @override
  String get screen_feature_trends_period_days90 => 'Last 3 months';

  @override
  String get screen_feature_trends_period_label => 'Period';

  @override
  String get screen_feature_trends_title => 'Trends';

  @override
  String get view_model_download_guidance_body =>
      'The on-device model for tips is not on this device yet. You can start preparing it. You can keep using the app meanwhile.';

  @override
  String get view_model_download_guidance_dismiss => 'Dismiss';

  @override
  String get view_model_download_guidance_prepare => 'Prepare model';

  @override
  String get view_model_download_guidance_prepare_failed =>
      'Preparation failed. Please try again later.';

  @override
  String get view_model_download_guidance_title => 'Prepare on-device AI model';
}
