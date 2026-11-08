import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_top_screen_metric/data_repository_top_screen_metric.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:riverpod/misc.dart';
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
import 'package:usecase_save_daily_goal/usecase_save_daily_goal.dart';
import 'package:usecase_save_daily_goal_impl/usecase_save_daily_goal_impl.dart';
import 'package:usecase_save_top_screen_metric/usecase_save_top_screen_metric.dart';
import 'package:usecase_save_top_screen_metric_impl/usecase_save_top_screen_metric_impl.dart';

/// トップ画面の読み込みと指標保存、一日あたり目標の読み書き、アドバイス生成、
/// 運動履歴の一覧・詳細読み込みを上書きする。
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
  GenerateTopAdviceUsecase.provider.overrideWith(
    (ref) => GenerateTopAdviceUsecaseImpl(
      llm: ref.watch(onDeviceLlmProvider),
      picker: adviceTemplatePicker,
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
];
