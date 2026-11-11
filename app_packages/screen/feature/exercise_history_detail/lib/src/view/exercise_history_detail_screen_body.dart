import 'dart:async';
import 'dart:io';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/entity/exercise_history_detail_screen_entity.dart';
import '../viewmodel/exercise_history_detail_screen_view_model.dart';
import 'exercise_history_detail_screen_providers.dart';

/// 詳細項目・写真・同一日ページめくり・不在／エラー表示。
///
/// Example:
/// ```dart
/// const ExerciseHistoryDetailScreenBody();
/// ```
@internal
class ExerciseHistoryDetailScreenBody extends HookConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryDetailScreenBody();
  /// ```
  const ExerciseHistoryDetailScreenBody({super.key});

  /// Entity を描画し、操作を ViewModel へ渡す。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryDetailScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(ExerciseHistoryDetailScreenProviders.entity);
    final viewModel = ref.watch(ExerciseHistoryDetailScreenViewModel.provider);
    final pageIndex = entity.pageCurrent - 1;
    final pageController = usePageController(
      initialPage: pageIndex < 0 ? 0 : pageIndex,
      keys: [entity.pageTotal, entity.showPagePosition],
    );

    return FScaffold(
      header: FHeader.nested(
        title: Text(strings.screen_feature_exercise_history_detail_title),
        prefixes: [FHeaderAction.back(onPress: viewModel.onBack)],
      ),
      child: entity.showLoading
          ? const Center(child: FCircularProgress())
          : entity.showMissing
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Text(
                    strings.screen_feature_exercise_history_detail_missing,
                    textAlign: TextAlign.center,
                  ),
                  FButton(
                    onPress: viewModel.onBack,
                    child: Text(
                      strings.screen_feature_exercise_history_detail_back,
                    ),
                  ),
                ],
              ),
            )
          : entity.showPagePosition
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    strings
                        .screen_feature_exercise_history_detail_page_position(
                          current: '${entity.pageCurrent}',
                          total: '${entity.pageTotal}',
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: entity.pageTotal,
                    onPageChanged: (index) {
                      unawaited(viewModel.onPageChanged(index: index));
                    },
                    itemBuilder: (context, index) {
                      if (index != pageIndex) {
                        return const SizedBox.shrink();
                      }
                      if (entity.showError) {
                        return Padding(
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
                                    strings
                                        .screen_feature_exercise_history_detail_retry,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }
                      if (entity.pageLoading) {
                        return const Center(child: FCircularProgress());
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _DetailFields(entity: entity),
                      );
                    },
                  ),
                ),
              ],
            )
          : entity.showError
          ? Padding(
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
                        strings.screen_feature_exercise_history_detail_retry,
                      ),
                    ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _DetailFields(entity: entity),
            ),
    );
  }
}

/// 詳細の各フィールドと写真。
final class _DetailFields extends StatelessWidget {
  /// [entity] の欄を縦に積む。
  const _DetailFields({required this.entity});

  /// 表示する詳細。
  final ExerciseHistoryDetailScreenEntity entity;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: [
      _Field(
        label: strings.screen_feature_exercise_history_detail_calories,
        value: entity.caloriesText,
      ),
      _Field(
        label: strings.screen_feature_exercise_history_detail_duration,
        value: entity.durationText,
      ),
      _Field(
        label: strings.screen_feature_exercise_history_detail_distance,
        value: entity.distanceText,
      ),
      _Field(
        label: strings.screen_feature_exercise_history_detail_created_at,
        value: entity.createdAtText,
      ),
      Text(
        strings.screen_feature_exercise_history_detail_photo,
        style: context.theme.typography.body.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
      if (entity.showPhoto)
        Image.file(
          File(entity.photoPath!),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Text(strings.screen_feature_exercise_history_detail_photo_error),
        )
      else if (entity.showPhotoError)
        Text(strings.screen_feature_exercise_history_detail_photo_error),
      _Field(
        label: strings.screen_feature_exercise_history_detail_captured_at,
        value: entity.capturedAtText,
      ),
      _Field(
        label: strings.screen_feature_exercise_history_detail_average_speed,
        value: entity.averageSpeedText,
      ),
      _Field(
        label: strings.screen_feature_exercise_history_detail_recorded_at,
        value: '${entity.recordedAtText}${entity.recordedAtEditedSuffix}',
      ),
      _Field(
        label: strings.screen_feature_exercise_history_detail_saved_at,
        value: entity.savedAtText,
      ),
    ],
  );
}

/// ラベルと値の 1 行。
final class _Field extends StatelessWidget {
  /// [label] と [value] を縦に積む。
  const _Field({required this.label, required this.value});

  /// 項目名。
  final String label;

  /// 表示値。
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 4,
    children: [
      Text(
        label,
        style: context.theme.typography.body.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
      Text(value, style: context.theme.typography.body.md),
    ],
  );
}
