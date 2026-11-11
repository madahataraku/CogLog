import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/entity/exercise_history_day_cell_entity.dart';

/// 月曜始まり・選択月のみの運動履歴カレンダー。
///
/// Example:
/// ```dart
/// ExerciseHistoryCalendar(
///   weekdayLabels: const ['月', '火', '水', '木', '金', '土', '日'],
///   dayCells: const [],
///   onDayPressed: (_) {},
/// );
/// ```
@internal
class ExerciseHistoryCalendar extends StatelessWidget {
  /// 曜日・セル・日付タップを受け取る。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryCalendar(
  ///   weekdayLabels: const ['月', '火', '水', '木', '金', '土', '日'],
  ///   dayCells: const [],
  ///   onDayPressed: (_) {},
  /// );
  /// ```
  const ExerciseHistoryCalendar({
    required this.weekdayLabels,
    required this.dayCells,
    required this.onDayPressed,
    super.key,
  });

  /// セルの高さ（論理ピクセル）。
  static const double cellHeight = 56;

  /// 月曜始まりの曜日ヘッダ。
  final List<String> weekdayLabels;

  /// グリッドに並べるセル。
  final List<ExerciseHistoryDayCellEntity> dayCells;

  /// スタンプ日タップ時に呼ばれる。
  final void Function(int day) onDayPressed;

  /// 曜日行と日付グリッドを描く。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryCalendar(
  ///   weekdayLabels: const ['月', '火', '水', '木', '金', '土', '日'],
  ///   dayCells: const [],
  ///   onDayPressed: (_) {},
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      children: [
        Row(
          children: [
            for (final w in weekdayLabels)
              Expanded(
                child: Center(child: Text(w, style: theme.typography.body.sm)),
              ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dayCells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: cellHeight,
          ),
          itemBuilder: (context, i) {
            final cell = dayCells[i];
            if (cell.day == null) {
              return const SizedBox.shrink();
            }
            return Semantics(
              label: cell.semanticsLabel,
              button: cell.isTappable,
              child: GestureDetector(
                onTap: cell.isTappable ? () => onDayPressed(cell.day!) : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${cell.day}', style: theme.typography.body.sm),
                    if (cell.stampCount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (cell.stampCount >= 2) ...[
                            const SizedBox(width: 2),
                            Text(
                              strings
                                  .screen_feature_exercise_history_count_badge(
                                    count: '${cell.stampCount}',
                                  ),
                              style: theme.typography.body.xs,
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
