/// 運動履歴と、本日・今週・今月の合計。
///
/// 期間の境界と表記は画面から再利用する。
///
/// Example:
/// ```dart
/// final window = PeriodWindow.today(DateTime(2026, 11, 5));
/// ```
library;

export 'src/average_speed.dart';
export 'src/consecutive_exercise_days.dart';
export 'src/days_since_previous_exercise_day.dart';
export 'src/exercise_history.dart';
export 'src/meter_duration_parser.dart';
export 'src/meter_ocr_token.dart';
export 'src/meter_panel_text_parser.dart';
export 'src/meter_reading_merger.dart';
export 'src/meter_reading_message_kind.dart';
export 'src/meter_reading_values.dart';
export 'src/meter_spatial_layout_inferencer.dart';
export 'src/period_aggregate.dart';
export 'src/period_total_metric.dart';
export 'src/period_total_text.dart';
export 'src/period_window.dart';
