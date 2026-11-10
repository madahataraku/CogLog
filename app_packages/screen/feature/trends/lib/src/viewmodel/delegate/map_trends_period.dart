import 'package:domain_trends/domain_trends.dart';

import '../state/trends_screen_state.dart';

/// 画面の期間選択を domain の期間種類へ写す。
///
/// Example:
/// ```dart
/// mapTrendsPeriod(TrendsPeriod.days30);
/// ```
TrendsPeriodKind mapTrendsPeriod(TrendsPeriod period) => switch (period) {
  TrendsPeriod.days30 => TrendsPeriodKind.days30,
  TrendsPeriod.days90 => TrendsPeriodKind.days90,
  TrendsPeriod.days182 => TrendsPeriodKind.days182,
  TrendsPeriod.days365 => TrendsPeriodKind.days365,
};
