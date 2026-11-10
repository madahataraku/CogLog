// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: depend_on_referenced_packages, implementation_imports, invalid_use_of_internal_member
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:monolith_localization_runtime/src/localize_string_delegate.dart';
import 'package:monolith_localization_runtime/src/localize_string_source.dart';

import 'l10n.dart';

/// e.g.
/// localizationsDelegates: [
///   L10nHelper.delegate,
///   GlobalMaterialLocalizations.delegate,
///   GlobalCupertinoLocalizations.delegate,
///   GlobalWidgetsLocalizations.delegate,
/// ]
final class L10nHelper {
  const L10nHelper._();

  /// L10n Delegate instance.
  static const delegate = _L10nHelperDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const supportedLocales = L10n.supportedLocales;

  static void configure(L10n? l10n) {
    if (l10n == null) {
      return;
    }
    final table = <String, String Function(LocalizeStringSource source)>{
      'app_count': (source) {
        // Has Placeholders
        var index = 0;
        String count = source.arguments[index];
        index++;
        return l10n.app_count(count);
      },
      'app_increase': (source) {
        // No Placeholders
        return l10n.app_increase;
      },
      'foundation_resources_app_name': (source) {
        // No Placeholders
        return l10n.foundation_resources_app_name;
      },
      'screen_feature_app_settings_back_semantics': (source) {
        // No Placeholders
        return l10n.screen_feature_app_settings_back_semantics;
      },
      'screen_feature_app_settings_debug_item': (source) {
        // No Placeholders
        return l10n.screen_feature_app_settings_debug_item;
      },
      'screen_feature_app_settings_title': (source) {
        // No Placeholders
        return l10n.screen_feature_app_settings_title;
      },
      'screen_feature_debug_availability_error_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_availability_error_label;
      },
      'screen_feature_debug_back_semantics': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_back_semantics;
      },
      'screen_feature_debug_backend_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_backend_label;
      },
      'screen_feature_debug_can_generate_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_can_generate_label;
      },
      'screen_feature_debug_clear_logs': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_clear_logs;
      },
      'screen_feature_debug_empty_logs': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_empty_logs;
      },
      'screen_feature_debug_generate_error_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_generate_error_label;
      },
      'screen_feature_debug_message_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_message_label;
      },
      'screen_feature_debug_no': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_no;
      },
      'screen_feature_debug_platform_notes_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_platform_notes_label;
      },
      'screen_feature_debug_probe_skipped_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_probe_skipped_label;
      },
      'screen_feature_debug_readiness_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_readiness_label;
      },
      'screen_feature_debug_reason_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_reason_label;
      },
      'screen_feature_debug_run_diagnose': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_run_diagnose;
      },
      'screen_feature_debug_running': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_running;
      },
      'screen_feature_debug_sample_output_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_sample_output_label;
      },
      'screen_feature_debug_section_availability': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_section_availability;
      },
      'screen_feature_debug_section_logs': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_section_logs;
      },
      'screen_feature_debug_section_probe': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_section_probe;
      },
      'screen_feature_debug_status_label': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_status_label;
      },
      'screen_feature_debug_title': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_title;
      },
      'screen_feature_debug_yes': (source) {
        // No Placeholders
        return l10n.screen_feature_debug_yes;
      },
      'screen_feature_exercise_history_calories': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_calories;
      },
      'screen_feature_exercise_history_calories_unit': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_calories_unit;
      },
      'screen_feature_exercise_history_created_at': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_created_at;
      },
      'screen_feature_exercise_history_detail_average_speed': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_average_speed;
      },
      'screen_feature_exercise_history_detail_average_speed_unit': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_average_speed_unit;
      },
      'screen_feature_exercise_history_detail_back': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_back;
      },
      'screen_feature_exercise_history_detail_calories': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_calories;
      },
      'screen_feature_exercise_history_detail_calories_unit': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_calories_unit;
      },
      'screen_feature_exercise_history_detail_captured_at': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_captured_at;
      },
      'screen_feature_exercise_history_detail_created_at': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_created_at;
      },
      'screen_feature_exercise_history_detail_distance': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_distance;
      },
      'screen_feature_exercise_history_detail_distance_unit': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_distance_unit;
      },
      'screen_feature_exercise_history_detail_duration': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_duration;
      },
      'screen_feature_exercise_history_detail_edited': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_edited;
      },
      'screen_feature_exercise_history_detail_error': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_error;
      },
      'screen_feature_exercise_history_detail_missing': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_missing;
      },
      'screen_feature_exercise_history_detail_photo': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_photo;
      },
      'screen_feature_exercise_history_detail_photo_error': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_photo_error;
      },
      'screen_feature_exercise_history_detail_recorded_at': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_recorded_at;
      },
      'screen_feature_exercise_history_detail_retry': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_retry;
      },
      'screen_feature_exercise_history_detail_saved_at': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_saved_at;
      },
      'screen_feature_exercise_history_detail_title': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_detail_title;
      },
      'screen_feature_exercise_history_distance': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_distance;
      },
      'screen_feature_exercise_history_distance_unit': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_distance_unit;
      },
      'screen_feature_exercise_history_duration': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_duration;
      },
      'screen_feature_exercise_history_empty': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_empty;
      },
      'screen_feature_exercise_history_error': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_error;
      },
      'screen_feature_exercise_history_load_more_error': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_load_more_error;
      },
      'screen_feature_exercise_history_month_label': (source) {
        // Has Placeholders
        var index = 0;
        String year = source.arguments[index];
        index++;
        String month = source.arguments[index];
        index++;
        return l10n.screen_feature_exercise_history_month_label(year, month);
      },
      'screen_feature_exercise_history_retry': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_retry;
      },
      'screen_feature_exercise_history_title': (source) {
        // No Placeholders
        return l10n.screen_feature_exercise_history_title;
      },
      'screen_feature_goal_settings_auto_update_description': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_auto_update_description;
      },
      'screen_feature_goal_settings_auto_update_enabled': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_auto_update_enabled;
      },
      'screen_feature_goal_settings_auto_update_level': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_auto_update_level;
      },
      'screen_feature_goal_settings_auto_update_level_challenging': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_auto_update_level_challenging;
      },
      'screen_feature_goal_settings_auto_update_level_normal': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_auto_update_level_normal;
      },
      'screen_feature_goal_settings_auto_update_level_slow': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_auto_update_level_slow;
      },
      'screen_feature_goal_settings_calories_label': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_calories_label;
      },
      'screen_feature_goal_settings_calories_unit': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_calories_unit;
      },
      'screen_feature_goal_settings_distance_label': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_distance_label;
      },
      'screen_feature_goal_settings_distance_unit': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_distance_unit;
      },
      'screen_feature_goal_settings_duration_label': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_duration_label;
      },
      'screen_feature_goal_settings_hours_label': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_hours_label;
      },
      'screen_feature_goal_settings_minutes_label': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_minutes_label;
      },
      'screen_feature_goal_settings_save': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_save;
      },
      'screen_feature_goal_settings_save_failed': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_save_failed;
      },
      'screen_feature_goal_settings_save_invalid_input': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_save_invalid_input;
      },
      'screen_feature_goal_settings_save_success': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_save_success;
      },
      'screen_feature_goal_settings_seconds_label': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_seconds_label;
      },
      'screen_feature_goal_settings_title': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_title;
      },
      'screen_feature_goal_settings_unset_hint': (source) {
        // No Placeholders
        return l10n.screen_feature_goal_settings_unset_hint;
      },
      'screen_feature_main_nav_exercise_history': (source) {
        // No Placeholders
        return l10n.screen_feature_main_nav_exercise_history;
      },
      'screen_feature_main_nav_goal_settings': (source) {
        // No Placeholders
        return l10n.screen_feature_main_nav_goal_settings;
      },
      'screen_feature_main_nav_home': (source) {
        // No Placeholders
        return l10n.screen_feature_main_nav_home;
      },
      'screen_feature_main_nav_meter_capture': (source) {
        // No Placeholders
        return l10n.screen_feature_main_nav_meter_capture;
      },
      'screen_feature_meter_capture_average_speed': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_average_speed;
      },
      'screen_feature_meter_capture_back': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_back;
      },
      'screen_feature_meter_capture_calories': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_calories;
      },
      'screen_feature_meter_capture_capture_photo': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_capture_photo;
      },
      'screen_feature_meter_capture_distance': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_distance;
      },
      'screen_feature_meter_capture_duration_hours': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_duration_hours;
      },
      'screen_feature_meter_capture_duration_minutes': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_duration_minutes;
      },
      'screen_feature_meter_capture_duration_seconds': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_duration_seconds;
      },
      'screen_feature_meter_capture_goal_auto_updated': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_goal_auto_updated;
      },
      'screen_feature_meter_capture_open_settings': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_open_settings;
      },
      'screen_feature_meter_capture_permission_camera': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_permission_camera;
      },
      'screen_feature_meter_capture_permission_library': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_permission_library;
      },
      'screen_feature_meter_capture_pick_library': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_pick_library;
      },
      'screen_feature_meter_capture_reading': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_reading;
      },
      'screen_feature_meter_capture_recorded_at': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_recorded_at;
      },
      'screen_feature_meter_capture_save': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_save;
      },
      'screen_feature_meter_capture_save_failed': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_save_failed;
      },
      'screen_feature_meter_capture_title': (source) {
        // No Placeholders
        return l10n.screen_feature_meter_capture_title;
      },
      'screen_feature_top_achievement_title': (source) {
        // No Placeholders
        return l10n.screen_feature_top_achievement_title;
      },
      'screen_feature_top_actual_label': (source) {
        // No Placeholders
        return l10n.screen_feature_top_actual_label;
      },
      'screen_feature_top_advice_no_exercise': (source) {
        // No Placeholders
        return l10n.screen_feature_top_advice_no_exercise;
      },
      'screen_feature_top_advice_template_1': (source) {
        // No Placeholders
        return l10n.screen_feature_top_advice_template_1;
      },
      'screen_feature_top_advice_template_2': (source) {
        // No Placeholders
        return l10n.screen_feature_top_advice_template_2;
      },
      'screen_feature_top_advice_template_3': (source) {
        // No Placeholders
        return l10n.screen_feature_top_advice_template_3;
      },
      'screen_feature_top_advisor_semantics': (source) {
        // No Placeholders
        return l10n.screen_feature_top_advisor_semantics;
      },
      'screen_feature_top_calories': (source) {
        // No Placeholders
        return l10n.screen_feature_top_calories;
      },
      'screen_feature_top_calories_unit': (source) {
        // No Placeholders
        return l10n.screen_feature_top_calories_unit;
      },
      'screen_feature_top_distance': (source) {
        // No Placeholders
        return l10n.screen_feature_top_distance;
      },
      'screen_feature_top_distance_unit': (source) {
        // No Placeholders
        return l10n.screen_feature_top_distance_unit;
      },
      'screen_feature_top_duration': (source) {
        // No Placeholders
        return l10n.screen_feature_top_duration;
      },
      'screen_feature_top_goal_label': (source) {
        // No Placeholders
        return l10n.screen_feature_top_goal_label;
      },
      'screen_feature_top_settings_semantics': (source) {
        // No Placeholders
        return l10n.screen_feature_top_settings_semantics;
      },
      'screen_feature_top_this_month': (source) {
        // No Placeholders
        return l10n.screen_feature_top_this_month;
      },
      'screen_feature_top_this_week': (source) {
        // No Placeholders
        return l10n.screen_feature_top_this_week;
      },
      'screen_feature_top_today': (source) {
        // No Placeholders
        return l10n.screen_feature_top_today;
      },
      'screen_feature_top_unset_prompt': (source) {
        // No Placeholders
        return l10n.screen_feature_top_unset_prompt;
      },
      'view_model_download_guidance_body': (source) {
        // No Placeholders
        return l10n.view_model_download_guidance_body;
      },
      'view_model_download_guidance_dismiss': (source) {
        // No Placeholders
        return l10n.view_model_download_guidance_dismiss;
      },
      'view_model_download_guidance_prepare': (source) {
        // No Placeholders
        return l10n.view_model_download_guidance_prepare;
      },
      'view_model_download_guidance_prepare_failed': (source) {
        // No Placeholders
        return l10n.view_model_download_guidance_prepare_failed;
      },
      'view_model_download_guidance_title': (source) {
        // No Placeholders
        return l10n.view_model_download_guidance_title;
      },
    };

    LocalizeStringDelegate.delegate = (source) {
      final id = source.id;
      final func = table[id]!;
      return func(source);
    };
  }
}

class _L10nHelperDelegate implements LocalizationsDelegate<L10n> {
  final delegate = L10n.delegate;

  const _L10nHelperDelegate();

  @override
  Type get type => delegate.type;

  @override
  bool isSupported(Locale locale) => delegate.isSupported(locale);

  @override
  Future<L10n> load(Locale locale) async {
    final result = await delegate.load(locale);
    L10nHelper.configure(result);
    return result;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<L10n> old) => false;
}
