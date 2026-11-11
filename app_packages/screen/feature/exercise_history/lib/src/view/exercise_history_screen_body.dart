import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/exercise_history_screen_view_model.dart';
import 'exercise_history_calendar.dart';
import 'exercise_history_screen_providers.dart';

/// 月切替・カレンダー・読込／エラー表示。
///
/// Example:
/// ```dart
/// const ExerciseHistoryScreenBody();
/// ```
@internal
class ExerciseHistoryScreenBody extends ConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryScreenBody();
  /// ```
  const ExerciseHistoryScreenBody({super.key});

  /// Entity を描画し、操作を ViewModel へ渡す。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(ExerciseHistoryScreenProviders.entity);
    final viewModel = ref.watch(ExerciseHistoryScreenViewModel.provider);

    return FScaffold(
      header: FHeader(
        title: Text(strings.screen_feature_exercise_history_title),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                FButton.icon(
                  variant: .ghost,
                  onPress: viewModel.onSelectPreviousMonth,
                  child: context.theme.icons.chevronLeft(context),
                ),
                Expanded(
                  child: Text(
                    entity.monthLabel,
                    textAlign: TextAlign.center,
                    style: context.theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                FButton.icon(
                  variant: .ghost,
                  onPress: viewModel.onSelectNextMonth,
                  child: context.theme.icons.chevronRight(context),
                ),
              ],
            ),
          ),
          if (entity.showError)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  FAlert(
                    variant: .destructive,
                    title: Text(entity.errorText ?? ''),
                  ),
                  if (entity.canRetry)
                    FButton(
                      onPress: viewModel.onRetry,
                      child: Text(
                        strings.screen_feature_exercise_history_retry,
                      ),
                    ),
                ],
              ),
            )
          else if (entity.showLoading)
            const Expanded(child: Center(child: FCircularProgress()))
          else
            Expanded(
              child: SingleChildScrollView(
                child: ExerciseHistoryCalendar(
                  weekdayLabels: entity.weekdayLabels,
                  dayCells: entity.dayCells,
                  onDayPressed: (day) => viewModel.onTapDay(day: day),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
