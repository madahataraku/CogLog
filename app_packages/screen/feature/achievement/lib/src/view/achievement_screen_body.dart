import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/achievement_screen_view_model.dart';
import '../viewmodel/entity/achievement_row_entity.dart';
import '../viewmodel/entity/achievement_screen_entity.dart';
import 'achievement_screen_providers.dart';

/// アチーブメント一覧の見た目。
///
/// Example:
/// ```dart
/// const AchievementScreenBody();
/// ```
@internal
class AchievementScreenBody extends ConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreenBody();
  /// ```
  const AchievementScreenBody({super.key});

  /// Entity に応じて読込・一覧・失敗を描画する。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(AchievementScreenViewModel.provider);
    final entity = ref.watch(AchievementScreenProviders.entity);
    return FScaffold(
      header: FHeader.nested(
        title: Text(strings.screen_feature_achievement_title),
        prefixes: [
          FHeaderAction.back(
            onPress: viewModel.onBack,
            semanticsLabel: strings.screen_feature_achievement_back_semantics,
          ),
        ],
      ),
      child: switch (entity) {
        AchievementScreenLoadingEntity() => const Center(
          child: FCircularProgress(),
        ),
        AchievementScreenFailedEntity() => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              FAlert(
                variant: .destructive,
                title: Text(strings.screen_feature_achievement_load_failed),
              ),
              FButton(
                onPress: viewModel.onRetry,
                child: Text(strings.screen_feature_achievement_retry),
              ),
            ],
          ),
        ),
        AchievementScreenReadyEntity(:final rows) => ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: rows.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) =>
              _AchievementRowView(row: rows[index]),
        ),
      },
    );
  }
}

/// 1 行分の枠・名前・条件・進捗バー・新規ドット。
class _AchievementRowView extends StatelessWidget {
  /// [row] を枠付きで縦に並べる。
  ///
  /// Example:
  /// ```dart
  /// const _AchievementRowView(
  ///   row: AchievementRowEntity(
  ///     id: 'first_record',
  ///     name: '？？？？？',
  ///     condition: '初めて運動記録を登録する',
  ///     unlocked: false,
  ///     progressRatio: 0,
  ///     isNew: false,
  ///   ),
  /// );
  /// ```
  const _AchievementRowView({required this.row});

  /// 表示する行。
  final AchievementRowEntity row;

  /// 枠とゲージを描画する。
  ///
  /// Example:
  /// ```dart
  /// const _AchievementRowView(
  ///   row: AchievementRowEntity(
  ///     id: 'first_record',
  ///     name: '？？？？？',
  ///     condition: '初めて運動記録を登録する',
  ///     unlocked: false,
  ///     progressRatio: 0,
  ///     isNew: false,
  ///   ),
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    final titleStyle = context.theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w600,
    );
    final conditionStyle = context.theme.typography.body.sm.copyWith(
      color: context.theme.colors.mutedForeground,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: row.unlocked
            ? context.theme.colors.primary.withValues(alpha: 0.12)
            : context.theme.colors.background,
        border: Border.all(
          color: row.unlocked
              ? context.theme.colors.primary
              : context.theme.colors.border,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              children: [
                Expanded(child: Text(row.name, style: titleStyle)),
                if (row.isNew)
                  Semantics(
                    label: strings.screen_feature_achievement_new_semantics,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.theme.colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(width: 8, height: 8),
                    ),
                  ),
              ],
            ),
            Text(row.condition, style: conditionStyle),
            LinearProgressIndicator(
              value: row.unlocked ? 1.0 : row.progressRatio.clamp(0.0, 1.0),
            ),
          ],
        ),
      ),
    );
  }
}
