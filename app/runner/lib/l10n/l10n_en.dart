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
      'No exercise history this month';

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
  String get screen_feature_main_nav_meter_capture => 'Meter capture';

  @override
  String get screen_feature_meter_capture_title => 'Meter capture';

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
  String get screen_feature_top_this_month => 'This month';

  @override
  String get screen_feature_top_this_week => 'This week';

  @override
  String get screen_feature_top_today => 'Today';

  @override
  String get screen_feature_top_unset_prompt => 'Set a daily goal in Goals';
}
