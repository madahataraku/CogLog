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

/// 1 行分の名前・条件・未開放時の進捗バー。
class _AchievementRowView extends StatelessWidget {
  /// [row] を縦に並べる。
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
  ///   ),
  /// );
  /// ```
  const _AchievementRowView({required this.row});

  /// 表示する行。
  final AchievementRowEntity row;

  /// 名前と条件を出し、未開放なら進捗バーも出す。
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(row.name, style: titleStyle),
        Text(row.condition, style: conditionStyle),
        if (!row.unlocked)
          LinearProgressIndicator(value: row.progressRatio.clamp(0.0, 1.0)),
      ],
    );
  }
}
