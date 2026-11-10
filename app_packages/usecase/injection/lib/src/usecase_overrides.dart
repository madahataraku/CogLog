import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_top_screen_metric/data_repository_top_screen_metric.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_app_settings/infra_app_settings.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:infra_meter_photo/infra_meter_photo.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:riverpod/misc.dart';
import 'package:usecase_diagnose_on_device_llm/usecase_diagnose_on_device_llm.dart';
import 'package:usecase_diagnose_on_device_llm_impl/usecase_diagnose_on_device_llm_impl.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';
import 'package:usecase_evaluate_daily_goal_auto_update_impl/usecase_evaluate_daily_goal_auto_update_impl.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_generate_top_advice_impl/usecase_generate_top_advice_impl.dart';
import 'package:usecase_load_daily_goal/usecase_load_daily_goal.dart';
import 'package:usecase_load_daily_goal_impl/usecase_load_daily_goal_impl.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';
import 'package:usecase_load_exercise_history_detail_impl/usecase_load_exercise_history_detail_impl.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';
import 'package:usecase_load_exercise_history_page_impl/usecase_load_exercise_history_page_impl.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';
import 'package:usecase_load_top_screen_impl/usecase_load_top_screen_impl.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_obtain_meter_photo_impl/usecase_obtain_meter_photo_impl.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_on_device_llm_guidance_impl/usecase_on_device_llm_guidance_impl.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';
import 'package:usecase_open_app_settings_impl/usecase_open_app_settings_impl.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_read_meter_panel_impl/usecase_read_meter_panel_impl.dart';
import 'package:usecase_save_daily_goal/usecase_save_daily_goal.dart';
import 'package:usecase_save_daily_goal_impl/usecase_save_daily_goal_impl.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';
import 'package:usecase_save_meter_capture_impl/usecase_save_meter_capture_impl.dart';
import 'package:usecase_save_top_screen_metric/usecase_save_top_screen_metric.dart';
import 'package:usecase_save_top_screen_metric_impl/usecase_save_top_screen_metric_impl.dart';

/// トップ画面の読み込みと指標保存、一日あたり目標の読み書き、アドバイス生成、
/// 端末上 LLM 誘導、運動履歴の一覧・詳細読み込み、メーター記録の写真取得・読み取り・保存・設定起動を上書きする。
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
  LoadExerciseHistoryDetailUsecase.provider.overrideWith(
    (ref) => LoadExerciseHistoryDetailUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
    ),
  ),
  ObtainMeterPhotoUsecase.provider.overrideWith(
    (ref) => ObtainMeterPhotoUsecaseImpl(
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
      engines: ref.watch(meterReadingEnginesProvider),
    ),
  ),
  SaveMeterCaptureUsecase.provider.overrideWith(
    (ref) => SaveMeterCaptureUsecaseImpl(
      histories: ref.watch(exerciseHistoryRepositoryProvider),
      health: ref.watch(healthWorkoutWriterProvider),
      evaluateAutoUpdate: ref.watch(
        EvaluateDailyGoalAutoUpdateUsecase.provider,
      ),
    ),
  ),
];
