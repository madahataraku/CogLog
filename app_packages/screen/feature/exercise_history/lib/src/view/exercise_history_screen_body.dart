import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/exercise_history_screen_view_model.dart';
import 'exercise_history_screen_providers.dart';

/// 月切替・一覧・無限スクロール・再試行。
///
/// Example:
/// ```dart
/// const ExerciseHistoryScreenBody();
/// ```
@internal
class ExerciseHistoryScreenBody extends HookConsumerWidget {
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
    final controller = useScrollController();

    useEffect(() {
      void onScroll() {
        if (!controller.hasClients) {
          return;
        }
        final position = controller.position;
        if (position.pixels >= position.maxScrollExtent - 200) {
          viewModel.onLoadMore();
        }
      }

      controller.addListener(onScroll);
      return () => controller.removeListener(onScroll);
    }, [controller, viewModel]);

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
          if (entity.errorText != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  FAlert(variant: .destructive, title: Text(entity.errorText!)),
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
              child: RefreshIndicator(
                onRefresh: viewModel.onRefresh,
                child: entity.showEmpty
                    ? CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  strings.screen_feature_exercise_history_empty,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: controller,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            entity.items.length +
                            (entity.showLoadMoreSpinner ||
                                    entity.canRetryLoadMore
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index >= entity.items.length) {
                            if (entity.canRetryLoadMore) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  spacing: 8,
                                  children: [
                                    Text(entity.loadMoreErrorText ?? ''),
                                    FButton(
                                      onPress: viewModel.onRetry,
                                      child: Text(
                                        strings
                                            .screen_feature_exercise_history_retry,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: FCircularProgress()),
                            );
                          }
                          final item = entity.items[index];
                          return FTile(
                            title: Text(item.createdAtText),
                            subtitle: Text(
                              '${strings.screen_feature_exercise_history_calories}: '
                              '${item.caloriesText} '
                              '${strings.screen_feature_exercise_history_calories_unit}\n'
                              '${strings.screen_feature_exercise_history_duration}: '
                              '${item.durationText}\n'
                              '${strings.screen_feature_exercise_history_distance}: '
                              '${item.distanceText} '
                              '${strings.screen_feature_exercise_history_distance_unit}',
                            ),
                            onPress: () => viewModel.onTapItem(id: item.id),
                          );
                        },
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
