import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:data_repository_top_screen_metric/data_repository_top_screen_metric.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:foundation_debug_overrides/foundation_debug_overrides.dart';
import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';
import 'package:infra_app_settings/infra_app_settings.dart';
import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:infra_local_notification/infra_local_notification.dart';
import 'package:infra_meter_photo/infra_meter_photo.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_oss_license_catalog/infra_oss_license_catalog.dart';
import 'package:riverpod/misc.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';
import 'package:usecase_diagnose_on_device_llm_impl/usecase_diagnose_on_device_llm_impl.dart';
import 'package:usecase_evaluate_achievements/usecase_evaluate_achievements.dart';
import 'package:usecase_evaluate_achievements_impl/usecase_evaluate_achievements_impl.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';
import 'package:usecase_evaluate_daily_goal_auto_update_impl/usecase_evaluate_daily_goal_auto_update_impl.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_generate_top_advice_impl/usecase_generate_top_advice_impl.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_load_achievements_impl/usecase_load_achievements_impl.dart';
import 'package:usecase_load_app_runtime_info/usecase_load_app_runtime_info.dart';
import 'package:usecase_load_app_runtime_info_impl/usecase_load_app_runtime_info_impl.dart';
import 'package:usecase_load_daily_goal/usecase_load_daily_goal.dart';
import 'package:usecase_load_daily_goal_impl/usecase_load_daily_goal_impl.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';
import 'package:usecase_load_exercise_history_detail_impl/usecase_load_exercise_history_detail_impl.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day/usecase_load_exercise_histories_for_same_recorded_day.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day_impl/usecase_load_exercise_histories_for_same_recorded_day_impl.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';
import 'package:usecase_load_exercise_history_month_impl/usecase_load_exercise_history_month_impl.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';
import 'package:usecase_load_exercise_history_page_impl/usecase_load_exercise_history_page_impl.dart';
import 'package:usecase_load_oss_licenses/usecase_load_oss_licenses.dart';
import 'package:usecase_load_oss_licenses_impl/usecase_load_oss_licenses_impl.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';
import 'package:usecase_load_top_screen_impl/usecase_load_top_screen_impl.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';
import 'package:usecase_load_trends_impl/usecase_load_trends_impl.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';
import 'package:usecase_control_meter_in_app_camera_impl/usecase_control_meter_in_app_camera_impl.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_obtain_meter_photo_impl/usecase_obtain_meter_photo_impl.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_on_device_llm_guidance_impl/usecase_on_device_llm_guidance_impl.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';
import 'package:usecase_open_app_settings_impl/usecase_open_app_settings_impl.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_read_meter_panel_impl/usecase_read_meter_panel_impl.dart';
import 'package:usecase_request_health_body_permission/usecase_request_health_body_permission.dart';
import 'package:usecase_request_health_body_permission_impl/usecase_request_health_body_permission_impl.dart';
import 'package:usecase_save_daily_goal/usecase_save_daily_goal.dart';
import 'package:usecase_save_daily_goal_impl/usecase_save_daily_goal_impl.dart';
import 'package:usecase_load_notification_settings/usecase_load_notification_settings.dart';
import 'package:usecase_load_notification_settings_impl/usecase_load_notification_settings_impl.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';
import 'package:usecase_save_meter_capture_impl/usecase_save_meter_capture_impl.dart';
import 'package:usecase_update_exercise_history/usecase_update_exercise_history.dart';
import 'package:usecase_update_exercise_history_impl/usecase_update_exercise_history_impl.dart';
import 'package:usecase_delete_exercise_history/usecase_delete_exercise_history.dart';
import 'package:usecase_delete_exercise_history_impl/usecase_delete_exercise_history_impl.dart';
import 'package:usecase_save_notification_settings/usecase_save_notification_settings.dart';
import 'package:usecase_save_notification_settings_impl/usecase_save_notification_settings_impl.dart';
import 'package:usecase_save_top_screen_metric/usecase_save_top_screen_metric.dart';
import 'package:usecase_save_top_screen_metric_impl/usecase_save_top_screen_metric_impl.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';
import 'package:usecase_sync_exercise_reminder_impl/usecase_sync_exercise_reminder_impl.dart';

/// トップ・推移の読み込み、指標保存、一日あたり目標の読み書き、アドバイス生成、
/// 端末上 LLM 誘導、運動履歴の一覧・詳細読み込み・更新・削除、メーター記録の写真取得・読み取り・保存・設定起動、
/// ヘルス身体許可リクエストを上書きする。
///
/// [adviceTemplatePicker] を渡すと定型選択を差し替える（Golden 用）。
///
/// Example:
/// ```dart
/// usecaseOverrides();
/// ```
List<Override> usecaseOverrides({
  AdviceTemplatePicker? adviceTemplatePicker,
}) => [
  LoadTopScreenUsecase.provider.overrideWith(
    (ref) => LoadTopScreenUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
      metrics: ref.watch(topScreenMetricRepositoryProvider),
      goals: ref.watch(dailyGoalRepositoryProvider),
      newIndicator: ref.watch(LoadAchievementNewIndicatorUsecase.provider),
    ),
  ),
  LoadTrendsUsecase.provider.overrideWith(
    (ref) => LoadTrendsUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
      health: ref.watch(healthBodyMetricsSourceProvider),
    ),
  ),
  RequestHealthBodyPermissionUsecase.provider.overrideWith(
    (ref) => RequestHealthBodyPermissionUsecaseImpl(
      source: ref.watch(healthBodyMetricsSourceProvider),
    ),
  ),
  SaveTopScreenMetricUsecase.provider.overrideWith(
    (ref) => SaveTopScreenMetricUsecaseImpl(
      metrics: ref.watch(topScreenMetricRepositoryProvider),
    ),
  ),
  LoadDailyGoalUsecase.provider.overrideWith(
    (ref) =>
        LoadDailyGoalUsecaseImpl(goals: ref.watch(dailyGoalRepositoryProvider)),
  ),
  SaveDailyGoalUsecase.provider.overrideWith(
    (ref) =>
        SaveDailyGoalUsecaseImpl(goals: ref.watch(dailyGoalRepositoryProvider)),
  ),
  EvaluateDailyGoalAutoUpdateUsecase.provider.overrideWith(
    (ref) => EvaluateDailyGoalAutoUpdateUsecaseImpl(
      goals: ref.watch(dailyGoalRepositoryProvider),
      histories: ref.watch(exerciseHistoryRepositoryProvider),
    ),
  ),
  EvaluateAchievementsUsecase.provider.overrideWith(
    (ref) => EvaluateAchievementsUsecaseImpl(
      achievements: ref.watch(achievementRepositoryProvider),
      histories: ref.watch(exerciseHistoryRepositoryProvider),
    ),
  ),
  LoadAchievementsUsecase.provider.overrideWith(
    (ref) => LoadAchievementsUsecaseImpl(
      achievements: ref.watch(achievementRepositoryProvider),
      histories: ref.watch(exerciseHistoryRepositoryProvider),
      evaluate: ref.watch(EvaluateAchievementsUsecase.provider),
    ),
  ),
  MarkAchievementsViewedUsecase.provider.overrideWith(
    (ref) => MarkAchievementsViewedUsecaseImpl(
      achievements: ref.watch(achievementRepositoryProvider),
    ),
  ),
  LoadAchievementNewIndicatorUsecase.provider.overrideWith(
    (ref) => LoadAchievementNewIndicatorUsecaseImpl(
      achievements: ref.watch(achievementRepositoryProvider),
    ),
  ),
  GenerateTopAdviceUsecase.provider.overrideWith(
    (ref) => GenerateTopAdviceUsecaseImpl(
      llm: ref.watch(onDeviceLlmProvider),
      picker: adviceTemplatePicker,
      log: ref.watch(appLogStoreProvider),
    ),
  ),
  DiagnoseOnDeviceLlmUsecase.provider.overrideWith(
    (ref) => DiagnoseOnDeviceLlmUsecaseImpl(
      llm: ref.watch(onDeviceLlmProvider),
      log: ref.watch(appLogStoreProvider),
    ),
  ),
  LoadExerciseHistoryPageUsecase.provider.overrideWith(
    (ref) => LoadExerciseHistoryPageUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
    ),
  ),
  LoadExerciseHistoryMonthUsecase.provider.overrideWith(
    (ref) => LoadExerciseHistoryMonthUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
    ),
  ),
  LoadExerciseHistoriesForSameRecordedDayUsecase.provider.overrideWith(
    (ref) => LoadExerciseHistoriesForSameRecordedDayUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
    ),
  ),
  LoadExerciseHistoryDetailUsecase.provider.overrideWith(
    (ref) => LoadExerciseHistoryDetailUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
    ),
  ),
  LoadOssLicensesUsecase.provider.overrideWith(
    (ref) => LoadOssLicensesUsecaseImpl(
      catalog: ref.watch(OssLicenseCatalog.provider),
    ),
  ),
  LoadAppRuntimeInfoUsecase.provider.overrideWith(
    (ref) => LoadAppRuntimeInfoUsecaseImpl(
      reader: ref.watch(AppRuntimeInfoReader.provider),
    ),
  ),
  ObtainMeterPhotoUsecase.provider.overrideWith(
    (ref) => ObtainMeterPhotoUsecaseImpl(
      source: ref.watch(meterPhotoSourceProvider),
    ),
  ),
  ControlMeterInAppCameraUsecase.provider.overrideWith(
    (ref) => ControlMeterInAppCameraUsecaseImpl(
      source: ref.watch(meterPhotoSourceProvider),
    ),
  ),
  EvaluateOnDeviceLlmGuidanceUsecase.provider.overrideWith(
    (ref) => EvaluateOnDeviceLlmGuidanceUsecaseImpl(
      llm: ref.watch(onDeviceLlmProvider),
    ),
  ),
  PrepareOnDeviceLlmModelUsecase.provider.overrideWith(
    (ref) =>
        PrepareOnDeviceLlmModelUsecaseImpl(llm: ref.watch(onDeviceLlmProvider)),
  ),
  OpenAppSettingsUsecase.provider.overrideWith(
    (ref) => OpenAppSettingsUsecaseImpl(
      opener: ref.watch(appSettingsOpenerProvider),
    ),
  ),
  ReadMeterPanelUsecase.provider.overrideWith(
    (ref) => ReadMeterPanelUsecaseImpl(
      llm: ref.watch(onDeviceLlmProvider),
      llmEngine: ref.watch(meterReadingLlmEngineProvider),
      spatialEngine: ref.watch(meterReadingSpatialEngineProvider),
      forceSpatialOcr: ref.watch(forceSpatialOcrStoreProvider),
      log: ref.watch(appLogStoreProvider),
    ),
  ),
  SyncExerciseReminderUsecase.provider.overrideWith(
    (ref) => SyncExerciseReminderUsecaseImpl(
      settings: ref.watch(notificationSettingsRepositoryProvider),
      histories: ref.watch(exerciseHistoryRepositoryProvider),
      notifications: ref.watch(localNotificationGatewayProvider),
    ),
  ),
  LoadNotificationSettingsUsecase.provider.overrideWith(
    (ref) => LoadNotificationSettingsUsecaseImpl(
      settings: ref.watch(notificationSettingsRepositoryProvider),
      notifications: ref.watch(localNotificationGatewayProvider),
    ),
  ),
  SaveNotificationSettingsUsecase.provider.overrideWith(
    (ref) => SaveNotificationSettingsUsecaseImpl(
      settings: ref.watch(notificationSettingsRepositoryProvider),
      notifications: ref.watch(localNotificationGatewayProvider),
      sync: ref.watch(SyncExerciseReminderUsecase.provider),
    ),
  ),
  SaveMeterCaptureUsecase.provider.overrideWith(
    (ref) => SaveMeterCaptureUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
      health: ref.watch(healthWorkoutWriterProvider),
      evaluateAutoUpdate: ref.watch(
        EvaluateDailyGoalAutoUpdateUsecase.provider,
      ),
      evaluateAchievements: ref.watch(EvaluateAchievementsUsecase.provider),
      syncReminder: ref.watch(SyncExerciseReminderUsecase.provider),
    ),
  ),
  UpdateExerciseHistoryUsecase.provider.overrideWith(
    (ref) => UpdateExerciseHistoryUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
      health: ref.watch(healthWorkoutWriterProvider),
      evaluateAutoUpdate: ref.watch(
        EvaluateDailyGoalAutoUpdateUsecase.provider,
      ),
      evaluateAchievements: ref.watch(EvaluateAchievementsUsecase.provider),
      syncReminder: ref.watch(SyncExerciseReminderUsecase.provider),
    ),
  ),
  DeleteExerciseHistoryUsecase.provider.overrideWith(
    (ref) => DeleteExerciseHistoryUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
      health: ref.watch(healthWorkoutWriterProvider),
      evaluateAutoUpdate: ref.watch(
        EvaluateDailyGoalAutoUpdateUsecase.provider,
      ),
      evaluateAchievements: ref.watch(EvaluateAchievementsUsecase.provider),
      syncReminder: ref.watch(SyncExerciseReminderUsecase.provider),
    ),
  ),
];
